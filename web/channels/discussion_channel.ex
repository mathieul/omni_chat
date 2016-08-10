defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel
  alias OmniChat.Presence
  alias OmniChat.Discussion
  alias OmniChat.DiscussionMessage
  alias OmniChat.DiscussionMessageSerializer

  def join("discussion:" <> discussion_id, payload, socket) do
    if discussion_id == "hall" do
      send self, :after_hall_join
    else
      send self, {:after_single_join, discussion_id}
    end
    socket = remember_subscriber_info(socket, payload, subtopic: discussion_id)

    {:ok, socket}
  end

  def remember_subscriber_info(socket, info, subtopic: subtopic) do
    socket
    |> assign(:chatter_id, info["chatter_id"])
    |> assign(:nickname, info["nickname"])
    |> assign(:subtopic, subtopic)
  end

  def handle_info(:after_hall_join, socket) do
    track_presence(socket)
    push socket, "presence_state", Presence.list(socket)
    push_all_discussions(socket)

    {:noreply, socket}
  end

  def handle_info({:after_single_join, discussion_id}, socket) do
    messages = DiscussionMessage.fetch_recent_messages(discussion_id)
    collection_payload = JaSerializer.format(DiscussionMessageSerializer, messages)
    push socket, "messages", collection_payload

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

  def handle_in("send_message", %{"content" => content}, socket) do
    discussion = Repo.get(Discussion, socket.assigns.subtopic)
    message =
      discussion
      |> Ecto.build_assoc(:discussion_messages,
                          content: content,
                          chatter_id: socket.assigns.chatter_id)
      |> Repo.insert!
      |> Repo.preload(:chatter)

    broadcast socket, "message", JaSerializer.format(DiscussionMessageSerializer, message)

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
