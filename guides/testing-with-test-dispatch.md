# Testing with TestDispatch

This library was built to test if forms and links have the expected results in
controller tests when they would be dispatched.

It can be used with or without the implementation of
[TestSelector](https://github.com/DefactoSoftware/TestSelector).

## Testing a form

We will explain the workings with the following form.

```html
<form action="admin/users/create" method="post">
  <input name="_csrf_token" type="hidden" value="AHIqJmEUAxIvGy4HJ3oUGCMjChsLYBZ-SGgy7W1HElh3PKLsffgXXQO6">

  <label>Name</label>
  <input id="user_name" label="Name" name="user[name]" type="text">

  <label>Email</label>
  <input id="user_email" label="Email" name="user[email]" type="email">

  <label>Description</label>
  <textarea id="user_description" label="Description" name="user[description]" type="textarea"></textarea>

  <select id="user_role" name="user[role]">
    <option value="">Select a role</option>
    <option value="admin">Admin</option>
    <option value="moderator">Moderator</option>
  </select>

  <button type="submit">Create new user</button>
</form>
```

This form is shown on `/admin/users/new` the entity for this form is `user`.

To post the form as is we can use the following code:

```elixir
conn
|> get("/admin/users/new")
|> disptach_form_with(:user)
|> html_response(422) =~ "can't be blank"
```

A request is made to the router here with the method `POST` to the action
`/admin/users/create` and with the params `%{"user" => %{"name" => "",
"email" => "", "description" => "", "roles" => ""}}`

The `dispatch_form_with/3` will return a conn with the response of the
controller. In this case it has returned an error because all fields are left
blank.

To update the fields while posting, a map can be given that matches the fields.

```elixir
params = %{
  name: "Marcel",
  email: "marcel@example.com",
  description: "Securing this place",
  role: "moderator"
}

conn
|> get("/admin/users/new")
|> disptach_form_with(params, :user)
|> redirected_to(302) == "/admin/users/2"
```

Now that the params are given each key is matched to the keys in the form and
updated with the value that is provided. If the keys do not match they won't be
posted.

### TestSelector

Some forms can be created that only have a submit button and cannot be found
with an entity. In this we can use `TestSelector` to find the form and dispatch
it.

```html
<form action="admin/posts/1" method="delete" test-selector="posts-123-delete-post">
  <input name="_csrf_token" type="hidden" value="AHIqJmEUAxIvGy4HJ3oUGCMjChsLYBZ-SGgy7W1HElh3PKLsffgXXQO6">
  <button type="submit">Remove</button>
</form>
```

This form can be dispatched with

```elixir
conn
|> get("/admin/posts")
|> dispatch_form_with("post-123-delete-post")
|> html_response(200) =~ "Post is deleted"
```

More documentation on how to use TestSelector can be found in [TestSelectors wiki](
https://github.com/defactosoftware/test_selector/wiki/Usage-in-App)

## Testing Links

Links can also be dispatched and currently we can only do this by using
TestSelector. For this `dispatch_link/3` can be used.

For this example we can take a posts show page on `/posts/1`

```html
<div>
  <h1>Post</h1>
  <a href="/posts/1" data-method="delete" test-selector="post-123-delete-post">
   Remove
  </a>
  <table>
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
    <tr>
      <td>A better comment</td>
      <td>
        <a href="/posts/1/comments/2"
           data-method="post"
           test-value="1"
           test-selector="post-123-upvote-comment" >
          Upvote Comment
      </td>
    </tr>
  </table>
</div>
```

We can now delete this post in the controller test by doing:

```elixir
conn
|> get('/posts/1')
|> dispatch_link("post-123-delete-post")
|> html_response(200) =~ "Post was deleted"
```

The dispatch_link parses the page and tries to find `post-123-delete-post` it
take the method by the `data-method` attribute. The url to dispatch to is taken
from the `href`. In this case a `delete` request is done to `posts/1`.

To take a specific element from a list test-values can be used as third argument
of `dispatch_link/3`.

```elixir
conn
|> get('/posts/1')
|> dispatch_link("post-123-upvote-comment", "1")
|> html_response(200) =~ "Upvoted comment 2"
```

As expected here a post request is done to `/posts/1/comments/2` for the second comment.

If there is no `data-method` set dispatch_link/3 will do a `get` request by
default.
