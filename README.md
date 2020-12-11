[![Hex pm](http://img.shields.io/hexpm/v/test_dispatch.svg?style=flat)](https://hex.pm/packages/test_dispatch)
[![codecov](https://codecov.io/gh/DefactoSoftware/test_dispatch/branch/master/graph/badge.svg)](https://codecov.io/gh/DefactoSoftware/test_dispatch)
[![CircleCI](https://circleci.com/gh/DefactoSoftware/test_dispatch.svg?style=svg)](https://circleci.com/gh/DefactoSoftware/test_dispatch)

# TestDispatch

Helper to test the dispatch of Phoenix forms in Elixir applications. This will
make it easier to write integration tests to check if forms in Phoenix templates
will submit to the intended controller action with the right params.

## Documentation

Documentation can be found on [HexDocs](https://hexdocs.pm/test_dispatch)

## Dependencies

- [Floki](https://github.com/philss/floki) v0.25.x and up
- [TestSelector](https://github.com/DefactoSoftware/test_selector)

## Installation

The package can be installed
by adding `test_dispatch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:test_dispatch, "~> 0.2.3"}
  ]
end
```

## Use

Import TestDispatch in your test module or your test case and you can call
`dispatch_form/3` from there.

To use `dispatch_form/3` a request has to be made to a page where a form is
present. The conn that is received will be parsed by the `dispatch_form/3`
and the form will be dispatched with the attributes that are given or the
default values when they are not given.

```elixir
defmodule MyAppWeb.MyTest do
  use MyAppWeb.ConnCase
  import TestDispatch

  test "dispatches form with attributes and entity" do
    conn = build_conn()

    assert conn
           |> get(Routes.user_path(conn, :new))
           |> dispatch_form(%{name: "John Doe", email: "john@doe.com"}, :user)
           |> redirected_to(Routes.user_path(conn, :index))
  end

  test "dispatches form with default values and test_selector" do
    conn = build_conn()

    assert conn
           |> get(Routes.user_path(conn, :index))
           |> dispatch_form(User.IndexView.test_selector("batch-action"))
           |> html_response(200)
  end
end
```

`dispatch_form/3` will find a form in the HTML response of the given conn by
entity or by [test_selector](https://github.com/DefactoSoftware/test_selector),
or, if no entity or test_selector is provided, it will target the last form found
in the response.

Next it will look for form controls (inputs, selects), convert these to params
and use the attributes passed to `dispatch_form/3` to update the values of
the params. The params will now only contain field keys found in the controls of
the form.

If an entity is given, the params will be prepended by this entity. So for:

```elixir
dispatch_form(conn, %{name: "John Doe", email: "john@doe.com"}, :user)
```

this will result in the following params:

```elixir
%{"user" => %{name: "John Doe", email: "john@doe.com"}}
```

Ultimately, the conn is dispatched to the conn's `private.phoenix_endpoint`
using `Phoenix.ConnTest.dispatch/5`, with the params and with the method and
action found in the form.
