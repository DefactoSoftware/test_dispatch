defmodule TestDispatchTest.Quiz.Question.AnswerController do
  @moduledoc false
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%{params: %{"id" => _} = params} = conn, :create) do
    next_question = to_id(params)

    redirect(conn, to: "/quiz/1/question/#{next_question}")
  end

  def to_id(%{"id" => id, "direction" => "Next"}), do: String.to_integer(id) + 1
  def to_id(%{"id" => "0", "direction" => "Back"}), do: 0
  def to_id(%{"id" => id, "direction" => "Back"}), do: String.to_integer(id) - 1
end
