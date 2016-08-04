defmodule OmniChat.Discussion do
  use OmniChat.Web, :model
  alias OmniChat.DiscussionMessage
  alias OmniChat.Chatter

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

  def fetch_participant_nicknames(discussion) do
    query = from dm in DiscussionMessage,
      join: c in Chatter, on: c.id == dm.chatter_id,
      where: dm.discussion_id == ^discussion.id,
      distinct: c.nickname,
      select: c.nickname
    Repo.all query
  end
end
