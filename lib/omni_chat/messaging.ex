defmodule OmniChat.Messaging do
  alias ExTwilio.Message

  def send_message(to, body) do
    if enabled? do
      Message.create(from: calling_number, to: to, body: body)
    end
  end

  defp calling_number do
    Application.get_env(:omni_chat, :calling_number)
  end

  defp enabled? do
    !!Application.get_env(:omni_chat, :twilio_enabled)
  end
end
