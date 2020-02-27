# TestDispatchForm

Helper to test the dispatch of Phoenix forms in Elixir applications. This will
make it easier to write integration tests to check if forms in Phoenix templates
will submit to the intended controller action with the right params.

## Dependencies

- [Floki](https://github.com/philss/floki) v0.25.x and up
- [TestSelector](https://github.com/DefactoSoftware/test_selector)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_dispatch_form` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:test_dispatch_form, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/test_dispatch_form](https://hexdocs.pm/test_dispatch_form).

## Use

Import TestDispatchForm in your test module or your test case and you can call
`dispatch_form_with/3` from there.

```elixir
defmodule Project.Web.MyTest do
  import TestDispatchForm

  test "dispatches form" do
    TestDispatchForm.dispatch_form_with(conn, %{name: "John Doe", email: "john@doe.com"}, :user)
  end
end
```

`dispatch_form_with/3` will find a form in the HTML response of the given conn by
entity or by [test_selector](https://github.com/DefactoSoftware/test_selector),
or, if no entity or test_selector is provided, it will target the last form found
in the response.

Next it will look for form controls (inputs, selects), convert these to params
and use the attributes passed to `dispatch_form_with/3` to update the values of
the params. The params will now only contain field keys found in the controls of
the form.

If an entity is given, the params will be prepended by this entity. So for:

```elixir
TestDispatchForm.dispatch_form_with(conn, %{name: "John Doe", email: "john@doe.com"}, :user)
```

this will result in the following params:

```elixir
%{"user" => %{name: "John Doe", email: "john@doe.com"}}
```

Ultimately, the conn is dispatched to the given endpoint using
`Phoenix.ConnTest.dispatch/5`, with the params and with the method and action
found in the form.
