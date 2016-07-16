defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
    text conn, "phone number = #{phone_number}"
  end
end
