defmodule OmniChat.Authentication do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(options) do
      Keyword.fetch!(options, :auth_path)
  end

  def call(conn, auth_path) do
    chatter_id    = get_session(conn, :chatter_id)
    authenticated = get_session(conn, :authenticated)

    if chatter_id && authenticated do
      conn
      |> assign(:chatter_id, chatter_id)
    else
      conn
      |> put_flash(:error, "You must be authenticated to access that page")
      |> redirect(to: auth_path)
      |> halt
    end
  end

  def sign_out(conn) do
    conn
    |> put_session(:chatter_id, nil)
    |> put_session(:authenticated, false)
    |> assign(:chatter_id, nil)
  end
end
