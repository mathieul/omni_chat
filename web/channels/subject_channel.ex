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
    {:ok, _ } = Presence.track(socket, socket.assigns.chatter_id, %{
      online_at: inspect(System.system_time(:seconds)),
      nickname: socket.assigns.nickname,
      phone_number: socket.assigns.phone_number
    })
    push socket, "welcome", %{
      "user" => socket.assigns.nickname,
      "body" => "Your phone number is #{socket.assigns.phone_number} and id=#{socket.assigns.chatter_id}",
      "presences" => Presence.list(socket)
    }
    {:noreply, socket}
  end
end
