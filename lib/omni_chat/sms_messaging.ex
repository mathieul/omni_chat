defmodule OmniChat.SmsMessaging do
  require Logger
  alias ExTwilio.Message

  @white_list [ "6504300629", "6502624403", "5109141524", "5109194058",
                "4152502501", "4154254374", "3157949887", "6508688484" ]

  def send_message(to, body) do
    target_number = OmniChat.Chatter.normalize_phone_number(to)
    if enabled?() && white_listed?(target_number) do
      Message.create(from: calling_number(), to: target_number, body: body)
    else
      Logger.info "TWILIO: Message.create from: #{calling_number()}, to: #{target_number}, body: #{inspect body}"
    end
  end

  defp calling_number do
    Application.get_env(:omni_chat, :calling_number)
  end

  defp enabled? do
    !!Application.get_env(:omni_chat, :twilio_enabled)
  end

  defp white_listed?(number) do
    Enum.member?(@white_list, number)
  end
end
