defmodule TestDispatch.Email.Guards do
  @moduledoc false

  defguard email_matches?(email, from, subject, to)
           when (email.to == to and is_nil(subject) and is_nil(from)) or
                  (email.subject == subject and is_nil(from) and is_nil(to)) or
                  (email.from == from and is_nil(subject) and is_nil(to)) or
                  (email.from == from and email.subject == subject and is_nil(to)) or
                  (email.from == from and email.to == to and is_nil(subject)) or
                  (email.subject == subject and email.to == to and is_nil(from)) or
                  (email.from == from and email.to == to and email.subject == subject)
end
