defmodule OmniChat.SmsController do
  use OmniChat.Web, :controller
  alias OmniChat.Sms
  alias OmniChat.Chatter

  def reply(conn, %{"Body" => content, "From" => from}) do
    case Chatter.with_phone_number(from) |> Repo.one do
      nil ->
        twiml_response(conn, Sms.reply_sender_unknown)

      chatter ->
        if chatter.discussion_id == nil do
          twiml_response(conn, Sms.reply_no_subscription)
        else
          OmniChat.Messenger.send_message(content, chatter: chatter,
                                                   discussion_id: chatter.discussion_id)
          twiml_response(conn, Sms.reply_empty)
        end
    end
  end

  defp twiml_response(conn, content) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, content)
  end
end
