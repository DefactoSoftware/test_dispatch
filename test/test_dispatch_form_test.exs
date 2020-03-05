defmodule TestDispatchFormTest.Controller do
  import Plug.Conn, only: [put_resp_content_type: 2, resp: 3]

  def init(opts), do: opts

  def call(conn, :new) do
    body = File.read!("test/forms/_entity_and_form_controls.html")
    conn |> put_resp_content_type("text/html") |> resp(200, body)
  end

  def call(%{params: %{"user" => %{"name" => _, "email" => _, "roles" => _}}} = conn, :create) do
    conn |> put_resp_content_type("text/html") |> resp(200, "user created")
  end
end

defmodule TestDispatchFormTest.Router do
  use Phoenix.Router
  alias TestDispatchFormTest.Controller

  pipeline :browser do
    plug(:put_bypass, :browser)
  end

  scope "/users" do
    pipe_through(:browser)
    get("/new", Controller, :new)
    post("/create", Controller, :create)
  end

  def put_bypass(conn, pipeline) do
    bypassed = (conn.assigns[:bypassed] || []) ++ [pipeline]
    Plug.Conn.assign(conn, :bypassed, bypassed)
  end
end

defmodule TestDispatchFormTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import TestDispatchForm

  alias TestDispatchFormTest.Router

  Application.put_env(:test_dispatch_form, TestDispatchFormTest.Endpoint, [])

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :test_dispatch_form
    def init(opts), do: opts

    def call(conn, opts),
      do: super(conn, opts).private[:endpoint] |> put_in(opts) |> Router.call(Router.init([]))
  end

  @endpoint Endpoint

  setup do
    Endpoint.start_link()
    Logger.disable(self())
    {:ok, conn: build_conn()}
  end

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
