defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel

  def join("discussion:hall", payload, socket) do
    IO.puts ">>> <discussion:hall> <<<"
    {:ok, socket}
  end

  def join(name, payload, socket) do
    IO.puts ">>> #{name}"
    {:ok, socket}
  end
end
