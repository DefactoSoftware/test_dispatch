defmodule TestDispatch.Helpers.Error do
  @moduledoc false
  import TestDispatch.Helpers.HTML

  @doc false
  def raise_status(status) do
    raise(
      Plug.BadRequestError,
      "The provided conn had the status #{status} that doesn't fall into the 2xx range"
    )
  end

  @doc false
  def raise_no_button_found(forms, button_text) do
    raise("""
    No form found for the given button text: #{button_text}
    Found the button texts:

     #{all_buttons(forms)}
    """)
  end

  @doc false
  def not_found_raise(test_selector, nil) do
    raise("No `a` element found for just the selector #{inspect(test_selector)}")
  end

  def not_found_raise(test_selector, test_value) do
    raise(
      "No `a` element found for selector #{inspect(test_selector)} with value #{
        inspect(test_value)
      }"
    )
  end

  @doc false
  def raise_no_selector_found(selector) do
    raise("No form found for the given test_selector or entity: #{selector}")
  end

  defp all_buttons(html_tree) do
    all_submit_buttons = html_tree |> Floki.find("button[type=submit]")
    all_submit_inputs = html_tree |> Floki.find("input[type=submit]")

    (all_submit_inputs ++ all_submit_buttons)
    |> Enum.map(&(text([&1]) <> "\n "))
  end
end
