defmodule OmniChat.AuthenticationForm do
  defstruct authentication_code: nil
end

defimpl Phoenix.HTML.FormData, for: OmniChat.AuthenticationForm do
  def to_form(auth_form, options) do
    %Phoenix.HTML.Form{
      source: auth_form,
      impl: __MODULE__,
      id: options[:as],
      name: options[:as]
    }
  end

  def to_form(_, _, _, _) do
    %Phoenix.HTML.Form{}
  end

  def input_type(changeset, field) do
    :text_input
  end

  def input_validations(changeset, field) do
    [required: false]
  end
end

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
      |> redirect(to: home_path(conn, :todo))
    else
      conn
      |> put_flash(:error, "Sorry, I don't recognize this authentication code.")
      |> put_session(:authenticated, false)
      |> redirect(to: session_path(conn, :new))
    end
  end
end
