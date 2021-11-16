defmodule TestDispatch.ReceiveMailTest do
  use TestDispatch.ConnCase

  describe "receive_mail" do
    test "receive email with expected_fields: [subject, to, from]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{subject: "Post 1", to: "other@example.com", from: "me@app.com"})
    end

    test "receive email with expected_fields: [subject, to]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{subject: "Post 1", to: "other@example.com"})
    end

    test "receive email with expected_fields: [subject, from]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{subject: "Post 1", from: "me@app.com"})
    end

    test "receive email with expected_fields: [to, from]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{to: "other@example.com", from: "me@app.com"})
    end

    test "receive email with expected_fields: [from]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{from: "me@app.com"})
    end

    test "receive email with expected_fields: [to]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{to: "other@example.com"})
    end

    test "receive email with expected_fields: [subject]", %{conn: conn} do
      assert conn
             |> get("/posts/1")
             |> click_link("post-123-send-as-mail")
             |> receive_mail(%{subject: "Post 1"})
    end

    test "raises an error when the email details do not match, subject", %{conn: conn} do
      expected_fields = %{subject: "wrong subject"}

      assert_raise RuntimeError, wrong_subject_message(expected_fields), fn ->
        conn
        |> get("/posts/1")
        |> click_link("post-123-send-as-mail")
        |> receive_mail(expected_fields)
      end
    end

    test "raises an error when the email details do not match, subject and to", %{conn: conn} do
      expected_fields = %{subject: "wrong subject", to: "other@example.com"}

      assert_raise RuntimeError, wrong_subject_message(expected_fields), fn ->
        conn
        |> get("/posts/1")
        |> click_link("post-123-send-as-mail")
        |> receive_mail(expected_fields)
      end
    end

    test "raises an error when no email is sent", %{conn: conn} do
      assert_raise RuntimeError, "Failed to find any email", fn ->
        conn |> receive_mail()
      end
    end
  end

  def wrong_subject_message(expected_fields) do
    """
    Failed to receive an email with the expected expected_fields:
      #{inspect(expected_fields)}
    Found email with the following fields:
      %{from: \"me@app.com\", subject: \"Post 1\", to: \"other@example.com\"}
    """
  end
end
