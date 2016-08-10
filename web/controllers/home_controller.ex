defmodule OmniChat.HomeController do
  use OmniChat.Web, :controller

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:online]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def online(conn, _params) do
    case Repo.get(OmniChat.Chatter, conn.assigns.chatter_id) do
      nil ->
        conn
        |> OmniChat.Authentication.sign_out
        |> redirect(to: "/")
      chatter ->
        elm_app_config = %{
          "chatter_id" => chatter.id,
          "nickname" => chatter.nickname,
          "max_messages" => OmniChat.DiscussionMessage.max_messages
        }
        render conn, "online.html", chatter: chatter,
                                    elm_module: "Online",
                                    elm_app_config: elm_app_config
    end
  end
end
