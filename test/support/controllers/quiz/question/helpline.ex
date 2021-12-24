defmodule TestDispatchTest.Quiz.Question.HelplineController do
  @moduledoc false
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts), do: opts

  def call(%{params: %{"id" => id}} = conn, :create) do
    conn |> redirect(to: "/quiz/1/question/#{id}")
  end
end
