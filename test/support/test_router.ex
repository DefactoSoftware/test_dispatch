defmodule TestDispatchTest.Router do
  use Phoenix.Router
  use Plug.ErrorHandler
  alias TestDispatchTest.{Controller, Post, PostController, Quiz}

  pipeline :browser do
    plug(:put_bypass, :browser)
  end

  scope "/" do
    pipe_through(:browser)
    get("/users/index", Controller, :index)
    get("/users/new", Controller, :new)
    post("/users/create", Controller, :create)
    put("/users/:id", Controller, :update)
    post("/users/export", Controller, :export)

    get("/posts", PostController, :index)
    get("/posts/:id", PostController, :show)
    delete("/posts/:id", PostController, :delete)
    post("/posts/:post_id/comments/:id", Post.CommentController, :upvote)

    get("/quiz/:quiz_id/question/:id", Quiz.QuestionController, :show)
    post("/quiz/:quiz_id/question/:id/answer", Quiz.Question.AnswerController, :create)
  end

  def put_bypass(conn, pipeline) do
    bypassed = (conn.assigns[:bypassed] || []) ++ [pipeline]
    Plug.Conn.assign(conn, :bypassed, bypassed)
  end

  def handle_errors(conn, params) do
    super(conn, params)

    send_resp(conn, conn.status, "Something went wrong: #{inspect(params)}")
  end
end
