defmodule TestDispatchFormTest.Controller do
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  def init(opts), do: opts

  def call(conn, :new) do
    body = File.read!("test/support/forms/_entity_and_form_controls.html")
    conn |> put_resp_content_type("text/html") |> resp(200, body)
  end

  def call(%{params: %{"user" => %{"name" => _, "email" => _, "roles" => _}}} = conn, :create) do
    conn |> put_resp_content_type("text/html") |> resp(200, "user created")
  end
end
