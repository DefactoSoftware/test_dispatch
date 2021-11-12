defmodule TestDispatchTest do
  @moduledoc """
  For the click_link tests see `test/test_dispatch_link_test.exs`.
  For the `submit_form` tests see `test/test_dispatch_form_test.exs`.
  """

  use TestDispatch.ConnCase
  doctest TestDispatch, import: true, only: [follow_redirect: 2, receive_mail: 2]
end
