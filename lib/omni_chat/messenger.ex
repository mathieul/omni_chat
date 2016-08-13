defmodule OmniChat.Messenger do
  require Logger
  alias OmniChat.Repo
  alias OmniChat.Chatter
  alias OmniChat.DiscussionChannel
  alias OmniChat.DiscussionMessageSerializer
  alias OmniChat.SmsMessaging

  def send_message(content, chatter: chatter, discussion_id: discussion_id) do
    discussion_message =
      OmniChat.Discussion
      |> Repo.get!(discussion_id)
      |> Ecto.build_assoc(:discussion_messages, content: content, chatter_id: chatter.id)
      |> Repo.insert!
      |> Repo.preload(:chatter)

    propagate_message(discussion_message, chatter: chatter)
  end

  defp propagate_message(message, chatter: chatter) do
    channel_name = DiscussionChannel.channel_name(message.discussion_id)
    serialized_message = JaSerializer.format(DiscussionMessageSerializer, message)
    OmniChat.Endpoint.broadcast channel_name, "message", serialized_message

    chatter_ids =
      OmniChat.Presence.list(DiscussionChannel.channel_name(:hall))
      |> Map.keys
      |> Enum.map(&String.to_integer/1)
      |> Enum.concat([message.chatter_id])
      |> Enum.uniq

    formatted_message = "#{chatter.nickname}: #{message.content}"
    Chatter.for_discussion(message.discussion_id, except: chatter_ids)
    |> Repo.all
    |> Enum.each(fn chatter ->
        SmsMessaging.send_message(chatter.phone_number, formatted_message)
      end)
  end
end
