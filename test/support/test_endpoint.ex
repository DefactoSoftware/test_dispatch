defmodule TestDispatchFormTest.Endpoint do
  use Phoenix.Endpoint, otp_app: :test_dispatch_form
  alias TestDispatchFormTest.Router

  def init(opts), do: opts

  def call(conn, opts),
    do: super(conn, opts).private[:endpoint] |> put_in(opts) |> Router.call(Router.init([]))
end
