defmodule TestDispatchTest.PostController do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  def init(opts), do: opts

  def call(conn, :index) do
    body = File.read!("test/support/links/_post_index.html")
    set_html_resp(conn, 200, body)
  end

  def call(%{params: %{"id" => _id}} = conn, :show) do
    body = File.read!("test/support/links/_post_show.html")
    set_html_resp(conn, 200, body)
  end

  def call(%{params: %{"id" => _id}} = conn, :delete) do
    redirect(conn, to: "/posts")
  end

  defp set_html_resp(conn, status, body),
    do: conn |> put_resp_content_type("text/html") |> resp(status, body)
end
