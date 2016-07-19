defmodule OmniChat.SessionController do
  use OmniChat.Web, :controller

  alias OmniChat.Chatter

  def new(conn, _params) do
    changeset = Chatter.changeset(%Chatter{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
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
      redirect conn, to: session_path(conn, :confirm, chatter.id)
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def confirm(conn, %{"chatter_id" => chatter_id}) do
    chatter = Repo.get!(Chatter, chatter_id)

    conn
    |> assign(:chatter, chatter)
    |> render("confirm.html")
  end
end
