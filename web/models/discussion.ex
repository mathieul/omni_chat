defmodule OmniChat.Discussion do
  use OmniChat.Web, :model
  alias OmniChat.DiscussionMessage

  schema "discussions" do
    field :subject, :string

    has_many :discussion_messages, DiscussionMessage, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject])
    |> validate_required([:subject])
    |> unique_constraint(:subject)
  end
end
