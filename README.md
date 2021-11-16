[![Hex pm](http://img.shields.io/hexpm/v/test_dispatch.svg?style=flat)](https://hex.pm/packages/test_dispatch)
[![codecov](https://codecov.io/gh/DefactoSoftware/test_dispatch/branch/master/graph/badge.svg)](https://codecov.io/gh/DefactoSoftware/test_dispatch)
[![CircleCI](https://circleci.com/gh/DefactoSoftware/test_dispatch.svg?style=svg)](https://circleci.com/gh/DefactoSoftware/test_dispatch)

# TestDispatch

TestDispatch adds the ability to use controller tests as integration tests
without using headless browsers. It allows tests to submit forms, click on
links, follow redirects and receive mails.

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
    {:test_dispatch, "~> 0.3.1"}
  ]
end
```

## Usage


### submit_form
Import TestDispatch in your test module or your test case and you can call
`submit_form/3` from there.

To use `submit_form/3` a request has to be made to a page where a form is
present. The conn that is received will be parsed by the `submit_form/3`
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
           |> submit_form(%{name: "John Doe", email: "john@doe.com"}, :user)
           |> redirected_to(Routes.user_path(conn, :index))
  end

  test "dispatches form with default values and test_selector" do
    conn = build_conn()

    assert conn
           |> get(Routes.user_path(conn, :index))
           |> submit_form(User.IndexView.test_selector("batch-action"))
           |> html_response(200)
  end
end
```

`submit_form/3` will find a form in the HTML response of the given conn by
entity or by [test_selector](https://github.com/DefactoSoftware/test_selector),
or, if no entity or test_selector is provided, it will target the last form found
in the response.

Next it will look for form controls (inputs, selects), convert these to params
and use the attributes passed to `submit_form/3` to update the values of
the params. The params will now only contain field keys found in the controls of
the form.

If an entity is given, the params will be prepended by this entity. So for:

```elixir
submit_form(conn, %{name: "John Doe", email: "john@doe.com"}, :user)
```

this will result in the following params:

```elixir
%{"user" => %{name: "John Doe", email: "john@doe.com"}}
```

Ultimately, the conn is dispatched to the conn's `private.phoenix_endpoint`
using `Phoenix.ConnTest.dispatch/5`, with the params and with the method and
action found in the form.

### Clicking on links in mails

During the tests emails might be sent that we want to integrate in our flow. For
that there is `receive_mail/2`. It expects the conn as the first argument and
the found email will be added to the conn as the `resp_body`. Using the conn
combined with the `click_link/4` function you can simulate "clicking" on the
link in an email.

```elixir
build_conn()
|> get("/posts/1")
|> click_link("post-123-send-as-mail")
|> receive_mail()
|> click_link("post-123-show")
|> html_response(200)
```

TestDispatch expects the email to be sent with the message
`{:delivered_email, %{} = email}` where the mail should contain at least
the `to:`, `from:` and `subject:`, `html_body:` fields.

When the mail is not received it will raise an error. Specific emails can be
targeted by adding the `:subject`, `:to` or `:from` to the second argument of
receive mail in a map.

```elixir
receive_mail(conn, %{submit: "This exact message", to: "this_address@exmaple.com"})
```
