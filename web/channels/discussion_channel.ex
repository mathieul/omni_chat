defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel
  alias OmniChat.Presence

  def join("discussion:" <> discussion, payload, socket) do
    send self, :after_join
    socket = remember_subscriber_info(socket, payload, discussion: discussion)

    {:ok, socket}
  end

  def remember_subscriber_info(socket, info, discussion: discussion) do
    socket
    |> assign(:chatter_id, info["chatter_id"])
    |> assign(:nickname, info["nickname"])
    |> assign(:discussion, discussion)
  end

  def handle_info(:after_join, socket) do
    track_presence(socket)
    push socket, "init", %{
      "user" => socket.assigns.nickname,
      "body" => "Your id is #{socket.assigns.chatter_id} and discussion is #{socket.assigns.discussion}",
      "presences" => Presence.list(socket)
    }

    {:noreply, socket}
  end

  defp track_presence(socket) do
    {:ok, _ } = Presence.track(socket, socket.assigns.chatter_id, %{
      online_at: inspect(System.system_time(:seconds)),
      nickname:  socket.assigns.nickname
    })
  end
end
