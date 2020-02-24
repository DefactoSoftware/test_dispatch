defmodule DetroitWeb.TestHelpers.ConnHelper do
  @moduledoc """
  A module that contains functions that makes writing tests easier.
  """
  @form_methods ["post", "put", "delete", "get"]

  import DetroitWeb.TestHelpers.ViewHelpers,
    only: [attribute: 2, attribute: 3, parse_fragment: 1]

  import Phoenix.ConnTest, only: [dispatch: 5, html_response: 2]
  import TestSelector.Test.FlokiHelpers

  alias DetroitWeb.Endpoint

  @spec dispatch_form_with(%Plug.Conn{}, %{required(atom()) => term()}, binary() | atom() | nil) ::
          %Plug.Conn{}
  def dispatch_form_with(conn, attrs \\ %{}, entity_or_test_selector \\ nil)

  def dispatch_form_with(%Plug.Conn{} = conn, %{} = attrs, entity_or_test_selector)
      when is_binary(entity_or_test_selector) or
             is_nil(entity_or_test_selector) or
             is_atom(entity_or_test_selector) do
    {form, selector_type} = find_form(conn, entity_or_test_selector)
    selector_tuple = {selector_type, entity_or_test_selector}

    form
    |> find_inputs(selector_tuple)
    |> Enum.map(&input_to_tuple(&1, selector_tuple))
    |> update_input_values(attrs)
    |> prepend_entity(selector_tuple)
    |> send_to_action(form, conn)
  end

  def dispatch_form_with(conn, entity_or_test_selector, nil),
    do: dispatch_form_with(conn, %{}, entity_or_test_selector)

  defp find_inputs(form, {:entity, _} = entity_tuple),
    do: find_input_fields(form, entity_tuple)

  defp find_inputs(form, _) do
    fields = find_input_fields(form, "")
    selects = find_selects(form, "")

    Enum.uniq(fields ++ selects)
  end

  defp find_selects(form, _), do: Floki.find(form, "select")

  defp find_input_fields(form, {:entity, entity}), do: Floki.find(form, "*[id^=#{entity}_]")

  defp find_input_fields(form, _),
    do:
      form
      |> Floki.filter_out("input[type=hidden]")
      |> Floki.find("input")

  defp prepend_entity(attrs, {:entity, entity}), do: %{entity => attrs}
  defp prepend_entity(attrs, _), do: attrs

  defp update_input_values(list, attrs),
    do:
      Enum.reduce(list, %{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.get(attrs, key, value))
      end)

  defp input_to_tuple(input, entity_tuple),
    do: input |> elem(0) |> _input_to_tuple(input, entity_tuple)

  defp _input_to_tuple("textarea", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = Floki.text(input)

    {key, value}
  end

  defp _input_to_tuple("select", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = input |> Floki.find("option[selected=selected]") |> attribute("value")

    {key, value}
  end

  defp _input_to_tuple("input", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = attribute(input, "value")

    {key, value}
  end

  defp key_for_input(input, {:entity, entity}) do
    input
    |> attribute("id")
    |> String.replace_leading("#{entity}_", "")
    |> String.to_atom()
  end

  defp key_for_input(input, _) do
    input
    |> attribute("id")
    |> String.to_atom()
  end

  defp send_to_action(params, form, conn) do
    action = attribute(form, "action")
    method = get_method_of_form(form)

    dispatch(conn, Endpoint, method, action, params)
  end

  defp get_method_of_form(form),
    do:
      form
      |> attribute("input[name=_method]", "value")
      |> downcase
      |> method(form)

  defp method(method, _) when method in @form_methods, do: method
  defp method(_, form), do: attribute(form, "method") || "post"

  defp downcase(nil), do: nil
  defp downcase(string), do: String.downcase(string)

  defp find_form(%Plug.Conn{status: status} = conn, entity_or_test_selector)
       when status in 200..299 do
    conn
    |> html_response(status)
    |> parse_fragment()
    |> Floki.find("form")
    |> find_form_by(entity_or_test_selector)
  end

  defp find_form(%Plug.Conn{status: status}, _),
    do:
      raise(
        Plug.BadRequestError,
        "The provided conn had the status #{status} that doesn't fall into the 2xx range"
      )

  defp find_form_by(form, nil), do: {List.last(form), nil}

  defp find_form_by(form, entity_or_test_selector) do
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
end
