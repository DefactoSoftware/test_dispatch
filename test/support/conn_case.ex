defmodule TestDispatch.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      Application.put_env(:test_dispatch_form, TestDispatchTest.Endpoint, [])

      import Phoenix.ConnTest
      import TestDispatch
      import TestDispatchTest.Endpoint

      @endpoint TestDispatchTest.Endpoint
    end
  end

  setup_all do
    TestDispatchTest.Endpoint.start_link()
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  setup do
    Logger.disable(self())
  end
end
