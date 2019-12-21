defmodule DetroitWeb.TestHelpers.ConnHelper do
  @moduledoc """
  A module that contains functions that makes writing tests easier.
  """
  @form_methods ["post", "put", "delete", "get"]

  import DetroitWeb.TestHelpers, only: [attribute: 2, attribute: 3]
  import Phoenix.ConnTest, only: [dispatch: 5, html_response: 2]
  alias DetroitWeb.Endpoint

  @spec post_form_with(%Plug.Conn{}, %{required(atom()) => term()}, String.t() | atom() | nil) ::
          %Plug.Conn{}
  def(
    post_form_with(%Plug.Conn{} = conn, attrs, entity \\ nil)
    when is_binary(entity) or is_nil(entity) or is_atom(entity)
  ) do
    form = find_form(conn, entity)
    entity = to_string(entity)

    form
    |> find_input_fields(entity)
    |> Enum.map(&input_to_tuple(&1, entity))
    |> update_input_values(attrs)
    |> prepend_entity(entity)
    |> send_to_action(form, conn)
  end

  defp find_input_fields(form, ""),
    do:
      form
      |> Floki.filter_out("input[type=hidden]")
      |> Floki.find("input")

  defp find_input_fields(form, entity), do: Floki.find(form, "*[id^=#{entity}_]")

  defp prepend_entity(attrs, ""), do: attrs
  defp prepend_entity(attrs, entity), do: %{entity => attrs}

  defp update_input_values(list, attrs),
    do:
      Enum.reduce(list, %{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.get(attrs, key, value))
      end)

  defp input_to_tuple(input, entity) do
    value = attribute(input, "value")
    key = key_for_input(input, entity)

    {key, value}
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

  defp key_for_input(input, entity) do
    input
    |> attribute("id")
    |> String.replace_leading("#{entity}_", "")
    |> String.to_atom()
  end

  defp find_form(%Plug.Conn{status: status} = conn, nil) do
    conn
    |> html_response(status)
    |> Floki.find("form")
    |> List.last()
  end

  defp find_form(%Plug.Conn{status: status} = conn, entity) do
    conn
    |> html_response(status)
    |> Floki.find("form")
    |> Enum.find(fn form ->
      form
      |> Floki.find("*[id^=#{entity}_]")
      |> Enum.any?()
    end)
  end
end
