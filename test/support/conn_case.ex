defmodule TestDispatchForm.ConnCase do
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
      Application.put_env(:test_dispatch_form, TestDispatchFormTest.Endpoint, [])

      import Phoenix.ConnTest
      import TestDispatchForm
      import TestDispatchFormTest.Endpoint

      @endpoint TestDispatchFormTest.Endpoint
    end
  end

  setup do
    TestDispatchFormTest.Endpoint.start_link()
    Logger.disable(self())

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
