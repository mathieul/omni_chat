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
    push socket, "presence_state", Presence.list(socket)
    push socket, "all_discussions", %{
      discussions: [
        %{
          "subject" => "test subject",
          "participants" => [%{"nickname" => "mathieu"}, %{"nickname" => "zlaj"}],
          "last_activity_at" => "5 days ago"
        }
      ]
    }

    {:noreply, socket}
  end

  def handle_in("create_discussion", %{"subject" => subject}, socket) do
    IO.puts "DEBUG>>> create_discussion: #{inspect subject}"
    push socket, "all_discussions", %{
      discussions: [
        %{
          "subject" => subject,
          "participants" => [%{"nickname" => socket.assigns.nickname}],
          "last_activity_at" => "TODO"
        },
        %{
          "subject" => "test subject",
          "participants" => [%{"nickname" => "mathieu"}, %{"nickname" => "zlaj"}],
          "last_activity_at" => "5 days ago"
        }
      ]
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
