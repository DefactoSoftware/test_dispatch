defmodule TestDispatchForm do
  @moduledoc """
  A module that contains a function to test the dispatch of forms. This will
  make it easier to write integration tests to check if forms in Phoenix
  templates will submit to the intended controller action with the right params.
  """
  @form_methods ["post", "put", "delete", "get"]

  import Phoenix.ConnTest, only: [dispatch: 5, html_response: 2]
  import Phoenix.Controller, only: [endpoint_module: 1]
  import TestSelector.Test.FlokiHelpers

  @doc """
  Will find a form in the HTML response of the given conn by entity or by
  `TestSelector`, or, if no entity or test_selector is provided, it will target
  the last form found in the response.

  Next it will look for form controls (inputs, selects), convert these to params
  and use the attributes passed to `dispatch_form_with/3` to update the values
  of the params. The params will now only contain field keys found in the
  controls of the form.

  If an entity is given, the params will be prepended by this entity.

  Ultimately, the conn is dispatched to the conn's `private.phoenix_endpoint`
  using `Phoenix.ConnTest.dispatch/5`, with the params and with the method and
  action found in the form.
  """
  @spec dispatch_form_with(Plug.Conn.t(), %{required(atom()) => term()}, binary() | atom() | nil) ::
          Plug.Conn.t()
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
    textareas = find_textareas(form, "")

    Enum.uniq(fields ++ selects ++ textareas)
  end

  defp find_selects(form, _), do: Floki.find(form, "select")

  defp find_textareas(form, _), do: Floki.find(form, "textarea")

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
    do: input |> elem(0) |> _input_to_tuple([input], entity_tuple)

  defp _input_to_tuple("textarea", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = Floki.text(input)

    {key, value}
  end

  defp _input_to_tuple("select", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = input |> Floki.find("option[selected=selected]") |> floki_attribute("value")

    {key, value}
  end

  defp _input_to_tuple("input", input, entity_tuple) do
    key = key_for_input(input, entity_tuple)
    value = floki_attribute(input, "value")

    {key, value}
  end

  defp key_for_input(input, {:entity, entity}) do
    input
    |> floki_attribute("id")
    |> String.replace_prefix("#{entity}_", "")
    |> String.to_atom()
  end

  defp key_for_input(input, _) do
    input
    |> floki_attribute("id")
    |> String.to_atom()
  end

  defp send_to_action(params, form, conn) do
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

  defp find_form(%Plug.Conn{status: status} = conn, entity_or_test_selector)
       when status in 200..299 or status == 401 do
    conn
    |> html_response(status)
    |> Floki.parse_document!()
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

  @spec floki_attribute(binary | Floki.html_tree(), binary, binary() | nil | none()) ::
          binary() | nil
  defp floki_attribute(html, select, name \\ nil)
  defp floki_attribute(html, select, nil), do: html |> Floki.attribute(select) |> List.first()

  defp floki_attribute(html, select, name),
    do: html |> Floki.attribute(select, name) |> List.first()
end
