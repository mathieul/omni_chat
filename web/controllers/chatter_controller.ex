defmodule OmniChat.ChatterController do
  use OmniChat.Web, :controller
  alias OmniChat.Chatter

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:edit, :update]

  def new(conn, _params) do
    changeset = Chatter.changeset(%Chatter{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"chatter" => %{"phone_number" => phone_number}}) do
    changeset = Chatter.authentication_changeset(%Chatter{}, %{phone_number: phone_number})

    if changeset.valid? do
      # destroy any existing Chatter with this phone number
      changeset.changes.phone_number
      |> Chatter.with_phone_number
      |> Repo.delete_all

      # save authentication code with expiration as a new Chatter
      chatter = Repo.insert!(changeset)

      # send SMS with authentication code
      OmniChat.Messaging.send_message(chatter.phone_number, Chatter.authentication_message(chatter))

      # redirect to authentication code form (code + nickname)
      conn
      |> put_session(:chatter_id, chatter.id)
      |> redirect(to: session_path(conn, :new))
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, _params) do
    changeset =
      conn
      |> fetch_chatter
      |> Chatter.changeset

    render conn, "edit.html", changeset: changeset
  end

  defp fetch_chatter(conn) do
    Repo.get!(Chatter, conn.assigns.chatter_id)
  end

  def update(conn, %{"chatter" => %{"nickname" => nickname}}) do
    changeset = Chatter.changeset(fetch_chatter(conn), %{nickname: nickname})
    case Repo.update(changeset) do
      {:ok, _chatter} ->
        conn
        |> put_flash(:notice, "Ready for action!")
        |> redirect(to: home_path(conn, :todo))

      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end
end
