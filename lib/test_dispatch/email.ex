defmodule TestDispatch.Email do
  @moduledoc false

  @email_fields [:from, :subject, :to]

  @doc false
  def match_receive_mail(match) do
    to = Map.get(match, :to)
    subject = Map.get(match, :subject)
    from = Map.get(match, :from)

    receive do
      {:delivered_email, email}
      when email.to == to and is_nil(subject) and is_nil(from) ->
        email

      {:delivered_email, email}
      when email.subject == subject and is_nil(from) and is_nil(to) ->
        email

      {:delivered_email, email}
      when email.from == from and is_nil(subject) and is_nil(to) ->
        email

      {:delivered_email, email}
      when email.from == from and email.subject == subject and is_nil(to) ->
        email

      {:delivered_email, email}
      when email.from == from and email.to == to and is_nil(subject) ->
        email

      {:delivered_email, email}
      when email.subject == subject and email.to == to and is_nil(from) ->
        email

      {:delivered_email, email}
      when email.from == from and email.to == to and email.subject == subject ->
        email
    after
      100 -> raise_with_receive(match)
    end
  end

  def raise_with_receive(match) do
    receive do
      {:delivered_email, email} ->
        raise("""
        Failed to receive an email with the expected expected_fields:
          #{inspect(Map.take(match, @email_fields))}
        Found email with the following fields:
          #{inspect(Map.take(email, @email_fields))}
        """)
    after
      100 -> raise("Failed to find any email")
    end
  end
end
