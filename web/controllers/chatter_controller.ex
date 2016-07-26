defmodule OmniChat.ChatterController do
  use OmniChat.Web, :controller
  alias OmniChat.Chatter

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:edit, :update]

  def new(conn, _params) do
    changeset = Chatter.changeset(%Chatter{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"chatter" => %{"phone_number" => phone_number}}) do
    chatter =
      phone_number
      |> Chatter.with_phone_number
      |> Repo.one

    changeset = if chatter do
      Chatter.changeset(chatter)
    else
      Chatter.authentication_changeset(%Chatter{}, %{phone_number: phone_number})
    end

    if changeset.valid? do
      chatter = Repo.insert_or_update!(changeset)

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
