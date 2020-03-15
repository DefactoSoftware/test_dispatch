# Testing with TestDispatch

This library was built to test if forms and links have the expected results in
controller tests when they would be dispatched.

It can be used with or without
[TestSelector](https://github.com/DefactoSoftware/TestSelector)

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
`/admin/users/create` and with the params `%{name: "", email: "", description:
"", roles: ""}`

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


