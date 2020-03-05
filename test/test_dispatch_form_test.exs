defmodule TestDispatchFormTest do
  use TestDispatchForm.ConnCase

  describe "form with entity and empty form controls" do
    test "dispatches form with attributes", %{conn: conn} do
      attrs = %{
        name: "John Doe",
        email: "john@doe.com",
        description: "Just a regular joe",
        roles: ["Admin", "moderator"]
      }

      %Plug.Conn{params: params} =
        conn = conn |> get("/users/new") |> dispatch_form_with(attrs, :user)

      assert html_response(conn, 200) == "user created"

      assert params == %{
               "user" => %{
                 "description" => "Just a regular joe",
                 "email" => "john@doe.com",
                 "name" => "John Doe",
                 "roles" => ["Admin", "moderator"]
               }
             }
    end

    test "dispatches form with attributes that do not comply with the form controls" do
    end

    test "dispatches form without attributes" do
    end

    test "dispatches form with form controls that do not have the entity in it's id" do
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

  test "raise when trying to find a form by test_selector while there is none" do
  end

  test "raise when trying to find a form by entity while there is none" do
  end

  test "raise if no form is found in the HTML response" do
  end
end
