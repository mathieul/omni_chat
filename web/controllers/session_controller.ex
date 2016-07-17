defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
    # generage authentication code xxx-xxx
    # save authentication code with expiration
    # send SMS with authentication code
    # redirect to authentication code form (code + nickname)
    redirect conn, to: session_path(conn, :confirm)
    # text conn, "phone number = #{normalize_phone_number phone_number}"
  end

  defp normalize_phone_number(number),
    do: Regex.replace(~r/\D+/, number, "")

  def confirm(conn, _params) do
    text conn, "TODO: render form with authentication code and nickname"
  end
end
