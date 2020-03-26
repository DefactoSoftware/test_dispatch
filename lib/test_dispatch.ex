defmodule TestDispatch do
  @moduledoc """
  A module that contains a function to test the dispatch of forms. This will
  make it easier to write integration tests to check if forms in Phoenix
  templates will submit to the intended controller action with the right params.
  """

  import Phoenix.ConnTest, only: [dispatch: 4, redirected_to: 2]
  import Phoenix.Controller, only: [endpoint_module: 1]
  import TestDispatch.Form
  import TestDispatch.Link

  @doc """
  Will find a form in the HTML response of the given conn by entity or by
  `TestSelector`, or, if no entity or test_selector is provided, it will target
  the last form found in the response.

  Next it will look for form controls (inputs, selects), convert these to params
  and use the attributes passed to `dispatch_form_with/3` to update the values
  of the params. The params will now only contain field keys found in the
  controls of the form.

  If an entity is given, the params will be prepended by this entity.

  Ultimately, the conn is dispatched to the conn's `private.phoenix_endpoint`
  using `Phoenix.ConnTest.dispatch/5`, with the params and with the method and
  action found in the form.
  """
  @spec dispatch_form_with(Plug.Conn.t(), %{}, binary() | atom() | nil) :: Plug.Conn.t()
  def dispatch_form_with(conn, attrs \\ %{}, entity_or_test_selector \\ nil)

  def dispatch_form_with(%Plug.Conn{} = conn, %{} = attrs, entity_or_test_selector)
      when is_binary(entity_or_test_selector) or
             is_nil(entity_or_test_selector) or
             is_atom(entity_or_test_selector) do
    {form, selector_type} = find_form(conn, entity_or_test_selector)
    selector_tuple = {selector_type, entity_or_test_selector}

    form
    |> find_inputs(selector_tuple)
    |> Enum.map(&input_to_tuple(&1, selector_tuple))
    |> update_input_values(attrs)
    |> prepend_entity(selector_tuple)
    |> send_to_action(form, conn)
  end

  def dispatch_form_with(conn, entity_or_test_selector, nil),
    do: dispatch_form_with(conn, %{}, entity_or_test_selector)

  @doc """
  Finds a link by a given conn, test_selector and an optional test_value.

  Hereby it tries to get a response from the conn and find the first `<a></a>` element that
  has the combination of the test_selector and test_value. The link that is found will be
  dispatched with  `Phoenix.ConnTest.dispatch/4`. The method will be derived from the link
  by the `data-method` attribute and has "get" as default. The path will be taken from the
  `href`.

  ## Examples

  With the given page on "/posts/1"

  ```html
  <html>
  <body>
    <h1>Post</h1>
    <a href="/posts/1" data-method="delete" test-selector="post-123-delete-post">
     Remove
    </a>
    <table>
      <th>Comment</td>
      <th>Upvote</td>
      <tr>
        <td>This is perfect</td>
        <td>
          <a href="/posts/1/comments/1"
             data-method="post"
             test-value="1"
             test-selector="post-123-upvote-comment" >
            Upvote Comment
        </td>
      </tr>
    </table>
  </body>
  </html>
  ```

      iex> conn = build_conn() |> get("/posts/1")
      iex> result = dispatch_link(conn, "post-123-delete-post")
      iex> with %Plug.Conn{request_path: "/posts/1", method: "DELETE"} <- result, do: :ok
      :ok

      iex> conn = build_conn() |> get("/posts/1")
      iex> result = dispatch_link(conn, "post-123-upvote-comment", "1")
      iex> with %Plug.Conn{request_path: "/posts/1/comments/1", method: "POST"} <- result, do: :ok
      :ok

  """
  @spec dispatch_link(Plug.Conn.t(), binary(), binary() | nil) :: Plug.Conn.t()
  def dispatch_link(%Plug.Conn{} = conn, test_selector, test_value \\ nil)
      when is_binary(test_selector) do
    link = find_link(conn, test_selector, test_value)

    endpoint = endpoint_module(conn)

    method = floki_attribute(link, "data-method") || "get"

    path = floki_attribute(link, "href")

    dispatch(conn, endpoint, method, path)
  end

  @doc """
  Will take a conn that was redirected. It takes the path that was redirected to and
  performs a get on it. If the status does not match the redirected status it will
  raise an error. By default the status is 302.

  ## Examples

      iex> conn = build_conn() |> get("/posts/1")
      iex> conn = dispatch_link(conn, "post-123-delete-post")
      iex> result = follow_redirect(conn, 302) |> html_response(200)
      iex> if result =~ "Posts Index", do: :ok
      :ok

  """
  @spec follow_redirect(Plug.Conn.t(), integer) :: Plug.Conn.t()
  def follow_redirect(conn, status \\ 302) do
    path = redirected_to(conn, status)
    endpoint = endpoint_module(conn)

    dispatch(conn, endpoint, "get", path)
  end
end
