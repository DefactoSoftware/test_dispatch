defmodule TestDispatchTest.Post.MailController do
  @moduledoc false
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%{params: %{"post_id" => post_id}} = conn, :send) do
    body = File.read!("test/support/mail/post_mail.html")

    send(
      self(),
      {:delivered_email,
       %{
         from: "me@app.com",
         to: "other@example.com",
         subject: "Post #{post_id}",
         text_body: "this is a text body",
         html_body: body
       }}
    )

    redirect(conn, to: "/posts/#{post_id}")
  end
end
