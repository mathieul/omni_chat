defmodule OmniChat.SubjectChannel do
  use OmniChat.Web, :channel

  def join("subject:lobby", _payload, socket) do
    IO.puts "DEBUG>>> join(subject:lobby)"
    send self, :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    IO.puts "DEBUG>>> handle_info(:after_join): broadcast! welcome"
    broadcast! socket, "welcome", %{"user" => "system", "body" => "Bonjour vous 😘"}
    {:no_reply, socket}
  end
end
