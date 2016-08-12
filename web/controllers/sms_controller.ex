defmodule OmniChat.SmsController do
  use OmniChat.Web, :controller

  def reply(conn, %{"Body" => body, "From" => from} = params) do
    Apex.ap ["SMS received:", params]

    send_resp conn, 200, OmniChat.Sms.render_empty(:test)
  end
end
