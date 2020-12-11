defmodule TestDispatchLinkTest do
  use TestDispatch.ConnCase
  doctest TestDispatch, import: true, only: [dispatch_link: 3]

  @post_show_body File.read!("test/support/links/_post_show.html")

  describe "dispatch_link" do
    test "dispatches a delete by only a test selector", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> dispatch_link("post-123-delete-post")
             |> redirected_to(302) == "/posts"
    end

    test "dispatches a post by test selector and test value", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> dispatch_link("post-123-upvote-comment", "1")
             |> redirected_to(302) == "/posts/1"
    end

    test "dispatches a get as fallback", %{conn: conn} do
      dispatched_conn =
        conn
        |> get("/posts")
        |> dispatch_link("post-index-1234-post-link", "1")

      assert dispatched_conn.request_path == "/posts/1"
      assert html_response(dispatched_conn, 200) == @post_show_body
    end

    test "raises an error when the selector with the value is not found", %{conn: conn} do
      assert_raise RuntimeError,
                   "No `a` element found for selector \"some-none-existing-selector\" with value \"nonexistingvalue\"",
                   fn ->
                     conn
                     |> get("/posts/1")
                     |> dispatch_link("some-none-existing-selector", "nonexistingvalue")
                   end
    end

    test "raises an error when the selector is not found", %{conn: conn} do
      assert_raise RuntimeError,
                   "No `a` element found for just the selector \"some-none-existing-selector\"",
                   fn ->
                     conn
                     |> get("/posts/1")
                     |> dispatch_link("some-none-existing-selector")
                   end
    end

    test "works with given floki tree", %{conn: conn} do
      conn = conn |> get("/posts")

      dispatched_conn =
        conn
        |> html_response(200)
        |> Floki.parse_fragment!()
        |> Floki.find("[test-selector=post-index-1234-post-item]")
        |> dispatch_link(conn, "post-index-1234-post-link", "1")

      assert dispatched_conn.request_path == "/posts/1"
      assert html_response(dispatched_conn, 200) == @post_show_body
    end

    test "test_selector should be a binary", %{conn: conn} do
      assert_raise FunctionClauseError, fn ->
        conn
        |> get("/posts/1")
        |> dispatch_link(%{})
      end
    end
  end
end
