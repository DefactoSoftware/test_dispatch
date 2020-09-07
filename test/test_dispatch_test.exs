defmodule TestDispatchTest do
  @moduledoc """
  For the dispatch_link tests see `test/test_dispatch_link_test.exs`.
  For the `dispatch_form` tests see `test/test_dispatch_form_test.exs`.
  """

  use TestDispatch.ConnCase
  doctest TestDispatch, import: true, only: [follow_redirect: 2]
end
