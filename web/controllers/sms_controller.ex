defmodule OmniChat.SmsController do
  use OmniChat.Web, :controller
  alias OmniChat.Sms
  alias OmniChat.Chatter
  alias OmniChat.DiscussionChannel

  def reply(conn, %{"Body" => body, "From" => from}) do
    case Chatter.with_phone_number(from) |> Repo.one do
      nil ->
        twiml_response(conn, Sms.reply_sender_unknown)

      chatter ->
        if chatter.discussion_id == nil do
          twiml_response(conn, Sms.reply_no_subscription)
        else
          propagate_message(body, chatter: chatter)
          twiml_response(conn, Sms.reply_empty)
        end
    end
  end

  defp twiml_response(conn, content) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, content)
  end

  defp propagate_message(message, chatter: chatter) do
    channel_name = DiscussionChannel.channel_name(chatter.discussion_id)
    OmniChat.Endpoint.broadcast channel_name, "message", JaSerializer.format(DiscussionMessageSerializer, message)

    chatter_ids =
      OmniChat.Presence.list(DiscussionChannel.channel_name(:hall))
      |> Map.keys
      |> Enum.map(&String.to_integer/1)
      |> Enum.concat([chatter.id])
      |> Enum.uniq

    Chatter.for_discussion(chatter.discussion_id, except: chatter_ids)
    |> Repo.all
    |> Enum.each(fn chatter -> send_text_message(chatter, message) end)
  end

  defp send_text_message(chatter, message) do
    OmniChat.Messaging.send_message(chatter.phone_number, message.content)
  end
end
