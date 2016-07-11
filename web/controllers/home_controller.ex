defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
