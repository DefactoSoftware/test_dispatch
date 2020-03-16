defmodule TestDispatchTest.Endpoint do
  use Phoenix.Endpoint, otp_app: :test_dispatch
  alias TestDispatchTest.Router

  def init(opts), do: opts

  def call(conn, opts),
    do: super(conn, opts).private[:endpoint] |> put_in(opts) |> Router.call(Router.init([]))
end
