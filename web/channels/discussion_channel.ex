defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel
  alias OmniChat.Presence
  alias OmniChat.Discussion

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
    push_all_discussions(socket)

    {:noreply, socket}
  end

  def handle_in("create_discussion", %{"subject" => subject}, socket) do
    changeset = Discussion.changeset(%Discussion{}, %{subject: subject})
    case Repo.insert(changeset) do
      {:ok, discussion} ->
        discussion
        |> Ecto.build_assoc(:discussion_messages,
                            content: welcome_message(discussion),
                            chatter_id: socket.assigns.chatter_id)
        |> Repo.insert!
      {:error, changeset} ->
        error_payload = Phoenix.View.render(OmniChat.ErrorView, "errors.json-api", data: changeset)
        push socket, "error", error_payload
      _ ->
      nil
    end
    push_all_discussions(socket)

    {:noreply, socket}
  end

  defp track_presence(socket) do
    {:ok, _ } = Presence.track(socket, socket.assigns.chatter_id, %{
      online_at: inspect(System.system_time(:seconds)),
      nickname:  socket.assigns.nickname
    })
  end

  defp push_all_discussions(socket) do
    discussions = Discussion.fetch_all_with_participants
    collection_payload = JaSerializer.format(OmniChat.DiscussionSerializer, discussions)
    push socket, "all_discussions", collection_payload
  end

  defp welcome_message(discussion) do
    "Hey there. So what about \"#{discussion.subject}\""
  end
end
