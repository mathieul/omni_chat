defmodule OmniChat.Router do
  use OmniChat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/", OmniChat do
    pipe_through :browser

    get "/", HomeController, :index
    get "/online", HomeController, :online
    resources "/chatter", ChatterController, only: [:new, :create, :edit, :update], singleton: true
    resources "/session", SessionController, only: [:new, :create, :delete], singleton: true
    get "/sign-out", SessionController, :delete
  end
end
