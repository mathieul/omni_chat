defmodule OmniChat.Factory do
  use ExMachina.Ecto, repo: OmniChat.Repo

  def chatter_factory do
    %OmniChat.Chatter{
      phone_number: "5555555555",
      authentication_code: "123456",
      nickname: "tester"
    }
  end
end
