defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel
  alias OmniChat.Presence
  alias OmniChat.Chatter
  alias OmniChat.Discussion
  alias OmniChat.DiscussionMessage
  alias OmniChat.DiscussionMessageSerializer

  @hall "discussion:hall"

  def channel_name(:hall), do: @hall
  def channel_name(id), do: "discussion:#{id}"

  def join(@hall, payload, socket) do
    send self, :after_hall_join
    socket = remember_subscriber_info(socket, payload, discussion_id: nil)

    {:ok, socket}
  end

  def join("discussion:" <> discussion_id, payload, socket) do
    send self, {:after_single_join, discussion_id}
    socket = remember_subscriber_info(socket, payload, discussion_id: discussion_id)

    {:ok, socket}
  end

  def handle_info(:after_hall_join, socket) do
    track_presence(socket)
    push socket, "presence_state", Presence.list(socket)
    send_all_discussions(socket, broadcast: false)

    {:noreply, socket}
  end

  def handle_info({:after_single_join, discussion_id}, socket) do
    subscribe_to_discussion(socket.assigns.chatter_id,
                            discussion_id: socket.assigns.discussion_id,
                            socket: socket)
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
        push_changeset_errors(changeset, socket)
      _ ->
      nil
    end
    send_all_discussions(socket, broadcast: true)

    {:noreply, socket}
  end

  def handle_in("send_message", %{"content" => content}, socket) do
    chatter = Repo.get!(Chatter, socket.assigns.chatter_id)
    OmniChat.Messenger.send_message(content, chatter: chatter,
                                             discussion_id: socket.assigns.discussion_id)

    {:noreply, socket}
  end

  def terminate({:shutdown, :left}, socket) do
    subscribe_to_discussion(socket.assigns.chatter_id, discussion_id: nil, socket: socket)
    :ok
  end

  def terminate(_, _) do
    :ok
  end

  defp push_changeset_errors(changeset, socket) do
    error_payload = Phoenix.View.render(OmniChat.ErrorView, "errors.json-api", data: changeset)
    push socket, "error", error_payload
  end

  defp remember_subscriber_info(socket, info, discussion_id: discussion_id) do
    socket
    |> assign(:chatter_id, info["chatter_id"])
    |> assign(:nickname, info["nickname"])
    |> assign(:discussion_id, discussion_id)
  end

  defp track_presence(socket) do
    {:ok, _ } = Presence.track(socket, socket.assigns.chatter_id, %{
      online_at: inspect(System.system_time(:seconds)),
      nickname:  socket.assigns.nickname
    })
  end

  defp send_all_discussions(socket, broadcast: broadcast) do
    discussions = Discussion.fetch_all_with_participants
    collection_payload = JaSerializer.format(OmniChat.DiscussionSerializer, discussions)
    if broadcast do
      broadcast socket, "all_discussions", collection_payload
    else
      push socket, "all_discussions", collection_payload
    end
  end

  defp welcome_message(discussion) do
    "Hey there. So what about \"#{discussion.subject}\""
  end

  defp subscribe_to_discussion(chatter_id, discussion_id: discussion_id, socket: socket) do
    case Repo.get(Chatter, chatter_id) do
      nil ->
        nil
      chatter ->
        changeset = Chatter.changeset(chatter, %{discussion_id: discussion_id})
        case Repo.update(changeset) do
          {:error, changeset} ->
            push_changeset_errors(changeset, socket)
          _ ->
          nil
        end
    end
  end
end
