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
        render conn, "online.html", chatter: chatter,
                                    elm_module: "Online",
                                    elm_app_config: elm_app_config(chatter)
    end
  end

  defp elm_app_config(chatter) do
    maybe_discussion_id = if chatter.discussion_id do
      Integer.to_string(chatter.discussion_id)
    end
    %{
      "chatter_id"          => Integer.to_string(chatter.id),
      "nickname"            => chatter.nickname,
      "max_messages"        => Integer.to_string(OmniChat.DiscussionMessage.max_messages),
      "maybe_discussion_id" => maybe_discussion_id,
      "socket_server"       => Application.get_env(:omni_chat, :socket_server)
    }
  end
end
