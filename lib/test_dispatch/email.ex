defmodule TestDispatch.Email do
  @moduledoc false

  @email_fields [:to, :subject, :from]

  @doc false
  def match_receive_mail(match) do
    email_match = Map.take(match, @email_fields)

    receive do
      {:delivered_email, ^email_match = email} -> email
    after
      100 -> raise_with_receive(email_match)
    end
  end

  def raise_with_receive(email_match) do
    receive do
      {:delivered_email, email} ->
        raise("""
        Failed to receive an email with the expected subject:
          #{inspect(email_match)}
        Found email with the following fields:
          #{inspect(Map.take(email, @email_fields))}
        """)
    after
      100 -> raise("Failed to find any email")
    end
  end
end
