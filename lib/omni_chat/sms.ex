defmodule OmniChat.Sms do
  import ExTwiml

  def reply_sender_unknown do
    twiml do
      message "You need to register on http://cloudigisafe.com to post messages."
    end
  end

  def reply_no_subscription do
    twiml do
      message "You first need to join a subscription to post messages (http://cloudigisafe.com/online)."
    end
  end
end
