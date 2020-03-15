defmodule TestDispatchTest.Post.CommentController do
  @moduledoc false
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%{params: %{"post_id" => post_id, "id" => _id}} = conn, :upvote) do
    redirect(conn, to: "/posts/#{post_id}")
  end
end
