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

  def update_input_values(list, attrs),
    do:
      Enum.reduce(list, %{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.get(attrs, key, value))
      end)

  def input_to_tuple(input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = input |> elem(0) |> _input_to_tuple([input])

    {key, value}
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

    key
    |> String.replace_prefix("#{entity}_", "")
    |> String.to_atom()
  end

  defp key_for_input(input, _) do
    id = input |> floki_attribute("id")

    key =
      if floki_attribute(input, "type") == "radio",
        do: String.replace_suffix(id, "_#{floki_attribute(input, "value")}", ""),
        else: id

    String.to_atom(key)
  end

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
