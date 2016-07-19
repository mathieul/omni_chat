defmodule OmniChat.AuthenticationForm do
  defstruct authentication_code: nil
end

defimpl Phoenix.HTML.FormData, for: OmniChat.AuthenticationForm do
  def to_form(_, _) do
    %Phoenix.HTML.Form{}
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
end
