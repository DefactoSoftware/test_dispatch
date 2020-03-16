defmodule TestDispatchTest.Controller do
  @moduledoc false
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  @required_user_params ~w(name email)s

  def init(opts), do: opts

  def call(conn, :index) do
    body = File.read!("test/support/forms/_test_selector_and_no_form_controls.html")
    set_html_resp(conn, 200, body)
  end

  def call(%{params: %{"form" => form}} = conn, :new) do
    body = File.read!("test/support/forms/_#{form}.html")
    set_html_resp(conn, 200, body)
  end

  def call(%{params: %{"user" => %{} = user_params}} = conn, :create) do
    if has_all_required_params?(user_params),
      do: set_html_resp(conn, 200, "user created"),
      else: set_html_resp(conn, 200, "not all required params are set")
  end

  def call(%{params: params} = conn, :create) do
    if has_all_required_params?(params),
      do: set_html_resp(conn, 200, "user created"),
      else: set_html_resp(conn, 200, "not all required params are set")
  end

  def call(conn, :export) do
    set_html_resp(conn, 200, "users exported")
  end

  defp set_html_resp(conn, status, body),
    do: conn |> put_resp_content_type("text/html") |> resp(status, body)

  defp has_all_required_params?(user_params) do
    required_subset_of_given_params = Map.take(user_params, @required_user_params)

    Enum.count(required_subset_of_given_params) == Enum.count(@required_user_params) and
      Enum.all?(required_subset_of_given_params, fn {_, v} -> is_binary(v) and v != "" end)
  end
end
