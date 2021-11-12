defmodule TestDispatch.ReceiveMailTest do
  use TestDispatch.ConnCase

  describe "receive_mail" do
    test "raises an error when the email details do not match", %{conn: conn} do
      assert_raise RuntimeError, wrong_subject_message(), fn ->
        conn
        |> get("/posts/1")
        |> click_link("post-123-send-as-mail")
        |> receive_mail(%{subject: "wrong subject"})
      end
    end

    test "raises an error when no email is sent", %{conn: conn} do
      assert_raise RuntimeError, "Failed to find any email", fn ->
        conn |> receive_mail()
      end
    end
  end

  def wrong_subject_message do
    """
    Failed to receive an email with the expected subject:
      %{subject: \"wrong subject\"}
    Found email with the following fields:
      %{from: \"me@app.com\", subject: \"Post 1\", to: \"other@example.com\"}
    """
  end
end
