defmodule OmniChat.SubjectChannel do
  use OmniChat.Web, :channel

  def join("subject:lobby", payload, socket) do
    send self, :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    broadcast! socket, "welcome", %{"user" => "system", "body" => "Bonjour vous 😘"}
    {:noreply, socket}
  end
end
