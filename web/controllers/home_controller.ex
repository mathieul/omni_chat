defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:online]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def online(conn, _params) do
    chatter = Repo.get(OmniChat.Chatter, conn.assigns.chatter_id)
    render conn, "online.html", chatter: chatter, elm_module: "Online"
  end
end
