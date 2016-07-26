defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  alias OmniChat.Chatter

  def new(conn, _params) do
    chatter_id = get_session(conn, :chatter_id)
    chatter = Repo.get!(Chatter, chatter_id)

    conn
    |> assign(:chatter, chatter)
    |> render("new.html", form: %OmniChat.AuthenticationForm{})
  end

  def create(conn, %{"session" => %{"authentication_code" => authentication_code}}) do
    chatter_id = get_session(conn, :chatter_id)
    chatter = Repo.get!(Chatter, chatter_id)

    if chatter.authentication_code == authentication_code do
      conn
      |> put_flash(:notice, "Thank you, you've been successfully identified")
      |> put_session(:authenticated, true)
      |> redirect(to: chatter_path(conn, :edit))
    else
      conn
      |> put_flash(:error, "Sorry, I don't recognize this authentication code.")
      |> put_session(:authenticated, false)
      |> redirect(to: session_path(conn, :new))
    end
  end
end
