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
        discussion_id =
          OmniChat.Subscription.find_by_chatter(chatter.id)
          |> Repo.all
          |> Enum.map(&(&1.discussion_id))
          |> List.first

        elm_app_config = %{
          "chatter_id"    => chatter.id,
          "nickname"      => chatter.nickname,
          "max_messages"  => OmniChat.DiscussionMessage.max_messages,
          "discussion_id" => discussion_id,
          "socket_server" => Application.get_env(:omni_chat, :socket_server)
        }

        render conn, "online.html", chatter: chatter,
                                    elm_module: "Online",
                                    elm_app_config: elm_app_config
    end
  end
end
