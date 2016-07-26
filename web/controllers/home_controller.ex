defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:todo]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def todo(conn, _params) do
    chatter = Repo.get(OmniChat.Chatter, conn.assigns.chatter_id)

    render conn, "todo.html", chatter: chatter
  end
end
