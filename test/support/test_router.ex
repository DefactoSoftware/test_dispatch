defmodule TestDispatchFormTest.Router do
  use Phoenix.Router
  use Plug.ErrorHandler
  alias TestDispatchFormTest.Controller

  pipeline :browser do
    plug(:put_bypass, :browser)
  end

  scope "/" do
    pipe_through(:browser)
    get("/users/index", Controller, :index)
    get("/users/new", Controller, :new)
    post("/users/create", Controller, :create)
    post("/users/export", Controller, :export)
  end

  def put_bypass(conn, pipeline) do
    bypassed = (conn.assigns[:bypassed] || []) ++ [pipeline]
    Plug.Conn.assign(conn, :bypassed, bypassed)
  end

  def handle_errors(conn, params) do
    super(conn, params)

    send_resp(conn, conn.status, "Something went wrong: #{inspect(params)}")
  end
end
