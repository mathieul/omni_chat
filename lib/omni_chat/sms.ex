defmodule OmniChat.Sms do
  import ExTwiml

  def render_empty(_whatever) do
    twiml do
    end
  end
end
