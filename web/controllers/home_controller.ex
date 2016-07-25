defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def todo(conn, _params) do
    render conn, "todo.html"
  end
end
