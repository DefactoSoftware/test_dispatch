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
  See `submit_form/3` for documentation.
  """
  @spec dispatch_form(Plug.Conn.t(), %{}, binary() | atom() | nil) :: Plug.Conn.t()
  def dispatch_form(conn, attrs \\ %{}, entity_or_test_selector \\ nil)

  def dispatch_form(%Plug.Conn{} = conn, %{} = attrs, entity_or_test_selector)
      when is_binary(entity_or_test_selector) or
             is_nil(entity_or_test_selector) or
             is_atom(entity_or_test_selector) do
    {form, selector_type} = find_form(conn, entity_or_test_selector)
    selector_tuple = {selector_type, entity_or_test_selector}

    _dispatch_form(conn, form, selector_tuple, attrs)
  end

  def dispatch_form(conn, entity_or_test_selector, nil),
    do: dispatch_form(conn, %{}, entity_or_test_selector)

  @doc """
  See `submit_form/3` for documentation.
  """
  @spec dispatch_form(Plug.Conn.t(), %{}, atom(), binary()) :: Plug.Conn.t()

  def dispatch_form(%Plug.Conn{} = conn, %{} = attrs, entity, test_selector) do
    {form, _} = find_form(conn, test_selector)
    selector_tuple = {:entity, entity}

    _dispatch_form(conn, form, selector_tuple, attrs)
  end

  @doc """
  Will find a form in the HTML response of the given conn by entity or by
  `TestSelector`, or, if no entity or test_selector is provided, it will target
  the last form found in the response.

  Next it will look for form controls (inputs, selects), convert these to params
  and use the attributes passed to `submit_form/3` to update the values
  of the params. The params will now only contain field keys found in the
  controls of the form.

  If an entity is given, the params will be prepended by this entity.

  Ultimately, the conn is dispatched to the conn's `private.phoenix_endpoint`
  using `Phoenix.ConnTest.dispatch/5`, with the params and with the method and
  action found in the form.
  """

  @spec submit_form(Plug.Conn.t(), %{}, binary() | atom() | nil) :: Plug.Conn.t()
  def submit_form(conn, attrs \\ %{}, entity_or_test_selector \\ nil),
    do: dispatch_form(conn, attrs, entity_or_test_selector)

  defp _dispatch_form(conn, form, selector_tuple, attrs) do
    form
    |> find_inputs(selector_tuple)
    |> Enum.map(&input_to_tuple(&1, selector_tuple))
    |> update_input_values(attrs)
    |> prepend_entity(selector_tuple)
    |> send_to_action(form, conn)
  end

  @doc """
  Works like `submit_form/3`. The test_selector is used to find the right form and the
  entity is used to find and fill the inputs correctly.
  """
  @spec submit_form(Plug.Conn.t(), %{}, atom(), binary()) :: Plug.Conn.t()

  def submit_form(conn, attrs, entity, test_selector),
    do: dispatch_form(conn, attrs, entity, test_selector)

  @doc """
  Works like `submit_form/3` but instead of an entity or test_selector it uses
  the text of the button to match on the third argument.

  ## Examples

      iex> submit_with_button(conn, %{answer_option: "elixir"}, "Finish Quiz")
      %Plug.Conn{params: %{"answer_option" => "elixir"})
  """
  @spec submit_with_button(Plug.Conn.t(), %{}, binary()) :: Plug.Conn.t()
  def submit_with_button(%Plug.Conn{} = conn, attrs \\ %{}, button_text) do
    {form, _} = find_form(conn, button_text: button_text)
    selector_tuple = {:button_text, button_text}

    _dispatch_form(conn, form, selector_tuple, attrs)
  end

  @doc """
  See `click_link/4` for documentation.
  """
  @spec dispatch_link(nil | Floki.html_tree(), Plug.Conn.t(), binary(), binary() | nil) ::
          Plug.Conn.t()
  def dispatch_link(floki_tree \\ nil, conn, test_selector, test_value \\ nil)

  def dispatch_link(nil, %Plug.Conn{} = conn, test_selector, test_value),
    do: dispatch_link(conn, test_selector, test_value, nil)

  def dispatch_link(floki_tree, %Plug.Conn{} = conn, test_selector, test_value)
      when is_list(floki_tree) and is_binary(test_selector),
      do:
        floki_tree
        |> find_link(test_selector, test_value)
        |> _dispatch_link(conn)

  def dispatch_link(%Plug.Conn{} = conn, test_selector, test_value, _tree)
      when is_binary(test_selector),
      do:
        conn
        |> find_link(test_selector, test_value)
        |> _dispatch_link(conn)

  @doc """
  Finds a link by a given conn, test_selector and an optional test_value.

  Hereby it tries to get a response from the conn and find the first `<a></a>` element that
  has the combination of the test_selector and test_value. The link that is found will be
  dispatched with `Phoenix.ConnTest.dispatch/4`. The method will be derived from the link
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
      iex> result = click_link(conn, "post-123-delete-post")
      iex> with %Plug.Conn{request_path: "/posts/1", method: "DELETE"} <- result, do: :ok
      :ok

      iex> conn = build_conn() |> get("/posts/1")
      iex> result = click_link(conn, "post-123-upvote-comment", "1")
      iex> with %Plug.Conn{request_path: "/posts/1/comments/1", method: "POST"} <- result, do: :ok
      :ok

  """

  def click_link(tree \\ nil, conn, test_selector, test_value \\ nil),
    do: dispatch_link(conn, test_selector, test_value, tree)

  def _dispatch_link(link, conn) do
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
