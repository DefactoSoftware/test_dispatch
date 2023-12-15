defmodule TestDispatch.FormTest do
  use TestDispatch.ConnCase

  @params %{
    user: %{
      roles: ["admin", "moderator"]
    }
  }
  setup %{conn: conn} do
    conn = Plug.Conn.put_private(conn, :phoenix_endpoint, @endpoint)
    {:ok, conn: conn}
  end

  describe "#send_to_action/3" do
    test "Send a request to the current path when no action is given", %{conn: conn} do
      conn = get(conn, "/users/index")

      form =
        {"form", [{"method", "get"}],
         [{"input", [{"name", "_method"}, {"type", "hidden"}, {"value", "get"}], []}]}

      assert TestDispatch.Form.send_to_action(@params, form, conn).request_path == "/users/index"
    end
  end
end
