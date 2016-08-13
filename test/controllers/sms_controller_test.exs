defmodule OmniChat.SmsControllerTest do
  use OmniChat.ConnCase
  import OmniChat.Factory

  describe "POST /api/sms/reply: when message not from a chatter" do
    setup [:post_valid_reply]

    test "returns XML document", %{conn: conn} do
      assert response_content_type(conn, :xml) =~ "application/xml"
    end

    test "tells Twilio to send sender-unknown reply", %{conn: conn} do
      assert response(conn, 200) =~ "<Message>You need to register on http://cloudigisafe.com to post messages.</Message>"
    end
  end

  describe "POST /api/sms/reply: when message from chatter but not subscribed" do
    setup [:create_chatter, :post_valid_reply]

    test "returns XML document", %{conn: conn} do
      assert response_content_type(conn, :xml) =~ "application/xml"
    end

    test "tells Twilio to send no-subscription reply", %{conn: conn} do
      assert response(conn, 200) =~ "<Message>You first need to join a subscription to post messages (http://cloudigisafe.com/online).</Message>"
    end
  end

  defp create_chatter(_context) do
    [chatter: insert(:chatter, phone_number: "4152228888")]
  end

  defp post_valid_reply(context) do
    conn = post context[:conn], "/api/sms/reply", Body: "content", From: "+14152228888"
    [conn: conn]
  end
end
