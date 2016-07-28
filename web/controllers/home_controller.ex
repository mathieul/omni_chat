defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:online]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def online(conn, _params) do
    chatter = Repo.get(OmniChat.Chatter, conn.assigns.chatter_id)
    elm_flags = %{
      "nickname" => chatter.nickname,
      "phone_number" => chatter.phone_number
    }
    render conn, "online.html", chatter: chatter,
                                elm_module: "Online",
                                elm_flags: elm_flags
  end
end
