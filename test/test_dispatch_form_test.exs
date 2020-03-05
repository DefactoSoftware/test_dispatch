defmodule TestDispatchFormTest do
  use TestDispatchForm.ConnCase

  describe "form with entity and empty form controls" do
    test "dispatches form with attributes", %{conn: conn} do
      attrs = %{
        name: "John Doe",
        email: "john@doe.com",
        description: "Just a regular joe",
        roles: ["Admin", "moderator"],
        non_existing_field: "This will not show up in the params"
      }

      %Plug.Conn{params: params} =
        dispatched_conn =
        conn
        |> get("/users/new", %{form: "entity_and_form_controls"})
        |> dispatch_form_with(attrs, :user)

      assert html_response(dispatched_conn, 200) == "user created"

      assert params == %{
               "user" => %{
                 "description" => "Just a regular joe",
                 "email" => "john@doe.com",
                 "name" => "John Doe",
                 "roles" => ["Admin", "moderator"]
               }
             }
    end

    test "dispatches form without attributes", %{conn: conn} do
      %Plug.Conn{params: params} =
        dispatched_conn =
        conn
        |> get("/users/new", %{form: "entity_and_form_controls"})
        |> dispatch_form_with(:user)

      assert html_response(dispatched_conn, 200) == "not all required params are set"

      assert params == %{
               "user" => %{
                 "description" => "",
                 "email" => nil,
                 "name" => nil,
                 "roles" => nil
               }
             }
    end
  end

  describe "form with entity and no form controls" do
    test "dispatches form without attributes" do
    end

    test "dispatches form and given attributes are ignored" do
    end
  end

  describe "form with test_selector and empty form controls" do
    test "dispatches form with attributes" do
    end

    test "dispatches form with attributes that do not comply with the form controls" do
    end

    test "dispatches form without attributes" do
    end

    test "dispatches form with form controls of type 'input', 'textarea' and 'select'" do
    end
  end

  describe "form with test_selector and no form controls" do
    test "dispatches form without attributes" do
    end

    test "dispatches form and given attributes are ignored" do
    end
  end

  describe "form without entity or test_selector and empty form controls" do
    test "dispatches form with attributes" do
    end

    test "dispatches form with attributes that do not comply with the form controls" do
    end

    test "dispatches form without attributes" do
    end

    test "dispatches form with form controls of type 'input', 'textarea' and 'select'" do
    end
  end

  describe "form without entity or test_selector and no form controls" do
    test "dispatches form without attributes" do
    end

    test "dispatches form and given attributes are ignored" do
    end
  end

  test "raise when trying to find a form by test_selector while there is none", %{conn: conn} do
    conn = get(conn, "/users/new", %{form: "only_form_controls"})

    assert_raise(
      RuntimeError,
      "No form found for the given test_selector or entity: new-user",
      fn ->
        dispatch_form_with(conn, "new-user")
      end
    )
  end

  test "raise when trying to find a form by entity while there is none", %{conn: conn} do
    conn = get(conn, "/users/new", %{form: "only_form_controls"})

    assert_raise(RuntimeError, "No form found for the given test_selector or entity: user", fn ->
      dispatch_form_with(conn, :user)
    end)
  end

  test "raise if no form is found in the HTML response", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.put_resp_content_type("text/html")
      |> Plug.Conn.resp(200, "no form here")

    assert_raise(RuntimeError, "No form found for the given test_selector or entity: user", fn ->
      dispatch_form_with(conn, :user)
    end)
  end
end
