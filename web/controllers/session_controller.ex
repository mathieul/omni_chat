defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end
