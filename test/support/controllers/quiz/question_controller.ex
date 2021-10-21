defmodule TestDispatchTest.Quiz.QuestionController do
  @moduledoc false
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  def init(opts), do: opts

  def call(%{params: %{"id" => id}} = conn, :show) do
    body = File.read!("test/support/forms/_quiz_1_question_#{id}_form.html")
    set_html_resp(conn, 200, body)
  end

  defp set_html_resp(conn, status, body),
    do: conn |> put_resp_content_type("text/html") |> resp(status, body)
end
