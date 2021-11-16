defmodule TestDispatch.Email do
  @moduledoc false

  @email_fields [:from, :subject, :to]

  import TestDispatch.Email.Guards
  @doc false
  def match_receive_mail(match) do
    to = Map.get(match, :to)
    subject = Map.get(match, :subject)
    from = Map.get(match, :from)

    receive do
      {:delivered_email, email} when email_matches?(email, from, subject, to) ->
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
