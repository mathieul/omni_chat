defmodule OmniChat.SubjectChannel do
  use OmniChat.Web, :channel

  alias OmniChat.Presence

  def join("subject:lobby", payload, socket) do
    send self, :after_join

    socket =
      socket
      |> assign(:chatter_id, payload["chatter_id"])
      |> assign(:phone_number, payload["phone_number"])
      |> assign(:nickname, payload["nickname"])

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _ } = Presence.track(socket, socket.assigns.nickname, %{
      online_at: inspect(System.system_time(:seconds))
    })
    push socket, "welcome #{socket.assigns.nickname}", %{
      "user" => "system",
      "body" => "Your phone number is #{socket.assigns.phone_number} and id=#{socket.assigns.chatter_id}",
      "presences" => Presence.list(socket)
    }
    {:noreply, socket}
  end
end
