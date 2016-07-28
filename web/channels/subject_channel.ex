defmodule OmniChat.SubjectChannel do
  use OmniChat.Web, :channel

  alias OmniChat.Presence

  def join("subject:lobby", payload, socket) do
    send self, :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    # Presence.track(socket)
    push socket, "welcome", %{
      "user" => "system",
      "body" => "Bonjour vous 😘",
      "presences" => Presence.list(socket)
    }
    {:noreply, socket}
  end
end
