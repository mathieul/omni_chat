defmodule OmniChat.Router do
  use OmniChat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", OmniChat do
    pipe_through :browser

    get "/", HomeController, :index
    resources "/session", SessionController, only: [:new, :create], singleton: true
    get "/session/confirm/:chatter_id", SessionController, :confirm
  end
end
