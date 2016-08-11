defmodule OmniChat.DiscussionChannel do
  use OmniChat.Web, :channel
  alias OmniChat.Presence
  alias OmniChat.Discussion
  alias OmniChat.DiscussionMessage
  alias OmniChat.DiscussionMessageSerializer
  alias OmniChat.Subscription

  @hall "discussion:hall"

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
    subscribe_to_discussion(socket)
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
    discussion = Repo.get(Discussion, socket.assigns.discussion_id)
    message =
      discussion
      |> Ecto.build_assoc(:discussion_messages,
                          content: content,
                          chatter_id: socket.assigns.chatter_id)
      |> Repo.insert!
      |> Repo.preload(:chatter)

    propagate_message(message, socket)

    {:noreply, socket}
  end

  def terminate({:shutdown, :left}, socket) do
    unsubscribe_from_discussion(socket)
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

  defp subscribe_to_discussion(socket) do
    params = Map.take(socket.assigns, [:chatter_id, :discussion_id])
    changeset = Subscription.changeset(%Subscription{}, params)
    case Repo.insert(changeset) do
      {:error, changeset} ->
        push_changeset_errors(changeset, socket)
      _ ->
      nil
    end
  end

  defp unsubscribe_from_discussion(socket) do
    Map.take(socket.assigns, [:chatter_id, :discussion_id])
    |> Subscription.find_by_discussion_and_chatter
    |> Repo.delete_all

    {:noreply, socket}
  end

  defp propagate_message(message, socket) do
    broadcast socket, "message", JaSerializer.format(DiscussionMessageSerializer, message)

    chatter_ids =
      Presence.list(@hall)
      |> Map.keys
      |> Enum.map(&String.to_integer/1)
      |> Enum.concat([socket.assigns.chatter_id])
      |> Enum.uniq

    %{discussion_id: socket.assigns.discussion_id, chatter_ids: chatter_ids}
    |> Subscription.find_by_discussion_not_those_chatters
    |> Repo.all
    |> Repo.preload(:chatter)
    |> Enum.map(&(&1.chatter))
    |> Enum.uniq
    |> Enum.each(fn chatter -> send_text_message(chatter, message) end)
  end

  defp send_text_message(chatter, message) do
    OmniChat.Messaging.send_message(chatter.phone_number, message.content)
  end
end
