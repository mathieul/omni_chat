defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
    text conn, "phone number = #{normalize_phone_number phone_number}"
  end

  defp normalize_phone_number(number),
    do: Regex.replace(~r/\D+/, number, "")
end
