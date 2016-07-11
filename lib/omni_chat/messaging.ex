defmodule OmniChat.Messaging do
  alias ExTwilio.Message

  def send_message(to, body) do
    Message.create(from: calling_number, to: to, body: body)
  end

  defp calling_number do
    Application.get_env(:omni_chat, :calling_number)
  end
end
