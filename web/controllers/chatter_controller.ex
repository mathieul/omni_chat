defmodule OmniChat.ChatterController do
  use OmniChat.Web, :controller
  alias OmniChat.Chatter
  alias OmniChat.SmsMessaging

  plug OmniChat.Authentication, [ auth_path: "/chatter/new" ] when action in [:edit, :update]

  def new(conn, _params) do
    if get_session(conn, :authenticated) do
      redirect conn, to: home_path(conn, :online)
    else
      changeset = Chatter.changeset(%Chatter{})
      render conn, "new.html", changeset: changeset
    end
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

    case Repo.insert_or_update(changeset) do
      {:ok, chatter} ->
        # send SMS with authentication code
        SmsMessaging.send_message(chatter.phone_number, Chatter.authentication_message(chatter))

        # redirect to authentication code form (code + nickname)
        conn
        |> put_session(:chatter_id, chatter.id)
        |> redirect(to: session_path(conn, :new))

      {:error, changeset} ->
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
        redirect conn, to: home_path(conn, :online)

      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end
end
