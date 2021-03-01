defmodule TestDispatch.Form do
  @moduledoc false
  @form_methods ["post", "put", "delete", "get"]

  import Phoenix.ConnTest, only: [dispatch: 5, html_response: 2]
  import Phoenix.Controller, only: [endpoint_module: 1]
  import TestSelector.Test.FlokiHelpers

  def find_inputs(form, {:entity, _} = entity_tuple),
    do: find_input_fields(form, entity_tuple)

  def find_inputs(form, _) do
    fields = find_input_fields(form, "")
    selects = find_selects(form, "")
    textareas = find_textareas(form, "")
    radio_buttons = find_radio_buttons(form, "")

    Enum.uniq(fields ++ selects ++ textareas ++ radio_buttons)
  end

  def find_radio_buttons(form, "") do
    radios = Floki.find(form, "input[type=radio]")

    checked = Enum.filter(radios, &floki_attribute(&1, "checked"))

    checked_names = Floki.attribute(checked, "name")

    other_radios =
      radios
      |> Enum.uniq_by(fn {_, list, _} ->
        list |> Enum.find(fn {key, _} -> "name" == key end) |> elem(1)
      end)
      |> Enum.reject(fn radio -> floki_attribute(radio, "name") in checked_names end)

    other_radios ++ checked
  end

  defp find_selects(form, _), do: Floki.find(form, "select")

  defp find_textareas(form, _), do: Floki.find(form, "textarea")

  defp find_input_fields(form, {:entity, entity}) do
    inputs =
      form
      |> Floki.find("*[id^=#{entity}_]")
      |> Floki.filter_out("input[type=radio]")

    inputs ++ find_radio_buttons(form, "")
  end

  defp find_input_fields(form, _),
    do:
      form
      |> Floki.filter_out("input[type=radio]")
      |> Floki.filter_out("input[type=hidden]")
      |> Floki.find("input")

  def prepend_entity(attrs, {:entity, entity}), do: %{entity => attrs}
  def prepend_entity(attrs, _), do: attrs

  def update_input_values(list, attrs \\ %{}) do
    Enum.reduce(list, %{}, fn item, acc ->
      case item do
        {key, value} ->
          Map.put(acc, key, Map.get(attrs, key, value))

        {key, index, {nested_key, value}} = tuple ->
          nested_attr =
            attrs |> Map.get(key, []) |> Enum.at(index, %{}) |> Map.get(nested_key, value)

          acc_nested_list = Map.get(acc, key, false)
          new_nested_list = update_nested_input_values(acc_nested_list, tuple, nested_attr)

          Map.put(acc, key, new_nested_list)
      end
    end)
  end

  def input_to_tuple(input, entity_tuple) do
    value = input |> elem(0) |> _input_to_tuple([input])

    case input |> key_for_input(entity_tuple) |> resolve_nested() do
      {key, index, nested_key} -> {key, index, {nested_key, value}}
      key -> {key, value}
    end
  end

  defp _input_to_tuple("textarea", input), do: Floki.text(input)
  defp _input_to_tuple("input", input), do: floki_attribute(input, "value")

  defp _input_to_tuple("select", input),
    do: input |> Floki.find("option[selected=selected]") |> floki_attribute("value")

  defp key_for_input(input, {:entity, entity}) do
    id = input |> floki_attribute("id")

    key =
      if floki_attribute(input, "type") == "radio",
        do: String.replace_suffix(id, "_#{floki_attribute(input, "value")}", ""),
        else: id

    String.replace_prefix(key, "#{entity}_", "")
  end

  defp key_for_input(input, _) do
    id = floki_attribute(input, "id")

    if floki_attribute(input, "type") == "radio",
      do: String.replace_suffix(id, "_#{floki_attribute(input, "value")}", ""),
      else: id
  end

  defp resolve_nested(key) do
    case Regex.split(~r{_\d*_}, key, include_captures: true) do
      [key, capture, nested_key] ->
        index =
          capture
          |> String.replace("_", "")
          |> String.to_integer()

        {String.to_atom(key), index, String.to_atom(nested_key)}

      _ ->
        String.to_atom(key)
    end
  end

  defp update_nested_input_values(false, {_, _, {nested_key, _}}, nested_attr),
    do: [Map.put(%{}, nested_key, nested_attr)]

  defp update_nested_input_values(acc_nested_list, {_, index, {nested_key, _}}, nested_attr)
       when length(acc_nested_list) > index,
       do: List.update_at(acc_nested_list, index, &Map.put(&1, nested_key, nested_attr))

  defp update_nested_input_values(acc_nested_list, {_, index, {nested_key, _}}, nested_attr),
    do: List.insert_at(acc_nested_list, index, Map.put(%{}, nested_key, nested_attr))

  def send_to_action(params, form, conn) do
    endpoint = endpoint_module(conn)
    method = get_method_of_form(form)
    action = floki_attribute(form, "action")

    dispatch(conn, endpoint, method, action, params)
  end

  defp get_method_of_form(form),
    do:
      form
      |> floki_attribute("input[name=_method]", "value")
      |> downcase
      |> method(form)

  defp method(method, _) when method in @form_methods, do: method
  defp method(_, form), do: floki_attribute(form, "method") || "post"

  defp downcase(nil), do: nil
  defp downcase(string), do: String.downcase(string)

  def find_form(%Plug.Conn{status: status} = conn, entity_or_test_selector)
      when status in 200..299 or status == 401 do
    conn
    |> parse_conn()
    |> Floki.find("form")
    |> find_form_by(entity_or_test_selector)
  end

  def find_form(%Plug.Conn{status: status}, _),
    do:
      raise(
        Plug.BadRequestError,
        "The provided conn had the status #{status} that doesn't fall into the 2xx range"
      )

  def find_form_by(form, nil), do: {List.last(form), nil}

  def find_form_by(form, entity_or_test_selector) do
    test_selector_result = Enum.find(form, &find_test_selector(&1, entity_or_test_selector))

    entity_result =
      Enum.find(form, &(&1 |> Floki.find("*[id^=#{entity_or_test_selector}_]") |> Enum.any?()))

    cond do
      is_tuple(test_selector_result) ->
        {test_selector_result, :test_selector}

      is_tuple(entity_result) ->
        {entity_result, :entity}

      true ->
        raise("No form found for the given test_selector or entity: #{entity_or_test_selector}")
    end
  end

  @spec floki_attribute(binary | Floki.html_tree(), binary, binary() | nil | none()) ::
          binary() | nil
  def floki_attribute(html, select, name \\ nil)
  def floki_attribute(html, select, nil), do: html |> Floki.attribute(select) |> List.first()

  def floki_attribute(html, select, name),
    do: html |> Floki.attribute(select, name) |> List.first()

  def parse_conn(%{status: status} = conn) do
    conn
    |> html_response(status)
    |> Floki.parse_document!()
  end
end
