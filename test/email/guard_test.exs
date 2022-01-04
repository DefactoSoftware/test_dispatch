defmodule TestDispatch.Email.GuardsTest do
  use TestDispatch.ConnCase, async: true
  alias TestDispatch.Email.Guards
  require TestDispatch.Email.Guards

  describe "email_matches?" do
    test "matches on all at once" do
      assert Guards.email_matches?(email(), "me@app.com", "Post ", "other@example.com")
    end

    test "matches when only to and subject are given" do
      assert Guards.email_matches?(email(), "me@app.com", "Post ", nil)
    end

    test "matches when only to and from are given" do
      assert Guards.email_matches?(email(), "me@app.com", nil, "other@example.com")
    end

    test "matches when only subject and from are given" do
      assert Guards.email_matches?(email(), nil, "Post ", "other@example.com")
    end

    test "matches when only to is given" do
      assert Guards.email_matches?(email(), "me@app.com", nil, nil)
    end

    test "matches when only subject is given" do
      assert Guards.email_matches?(email(), nil, "Post ", nil)
    end

    test "matches when only from is given" do
      assert Guards.email_matches?(email(), nil, nil, "other@example.com")
    end

    test "does not match when all are nil" do
      refute Guards.email_matches?(email(), nil, nil, nil)
    end

    test "does not match when to is wrong" do
      refute Guards.email_matches?(email(), "other@to.com", nil, nil)
    end

    test "does not match when subject is wrong" do
      refute Guards.email_matches?(email(), nil, "Unmatching subject", nil)
    end

    test "does not match when from is wrong" do
      refute Guards.email_matches?(email(), nil, nil, "not@existing.com")
    end
  end

  def email do
    %{
      from: "me@app.com",
      to: "other@example.com",
      subject: "Post ",
      text_body: "this is a text body",
      html_body: "<html><body></body></html>"
    }
  end
end
