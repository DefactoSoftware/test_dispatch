defmodule TestDispatch.Helpers.HTML do
  @moduledoc false

  @doc false
  def text(html_tree),
    do: html_tree |> Floki.text() |> String.replace(~r/\s+/, " ") |> String.trim()

  @spec floki_attribute(binary | Floki.html_tree(), binary, binary() | nil | none()) ::
          binary() | nil
  @doc false
  def floki_attribute(html, select, name \\ nil)
  def floki_attribute(html, select, nil), do: html |> Floki.attribute(select) |> List.first()

  def floki_attribute(html, select, name),
    do: html |> Floki.attribute(select, name) |> List.first()
end
