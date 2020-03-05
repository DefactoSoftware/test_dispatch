defmodule TestDispatchFormTest.Controller do
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  @required_user_params ~w(name email)s

  def init(opts), do: opts

  def call(%{params: %{"form" => form}} = conn, :new) do
    body = File.read!("test/support/forms/_#{form}.html")
    set_html_resp(conn, 200, body)
  end

  def call(%{params: %{"user" => %{}} = params} = conn, :create) do
    if has_all_required_params?(params),
      do: set_html_resp(conn, 200, "user created"),
      else: set_html_resp(conn, 200, "not all required params are set")
  end

  defp set_html_resp(conn, status, body),
    do: conn |> put_resp_content_type("text/html") |> resp(status, body)

  defp has_all_required_params?(%{"user" => user_params}) do
    !Enum.any?(user_params, fn {p, v} ->
      p in @required_user_params and (is_nil(v) or v == "")
    end)
  end
end
