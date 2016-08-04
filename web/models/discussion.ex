defmodule OmniChat.Discussion do
  use OmniChat.Web, :model
  alias OmniChat.DiscussionMessage
  alias OmniChat.Chatter
  alias OmniChat.Repo

  schema "discussions" do
    field :subject, :string
    field :participants, {:array, :string}, default: [], virtual: true

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

  def participant_nicknames_per_discussion(discussions) do
    discussion_ids = Enum.map(discussions, &(&1.id))

    from(dm in DiscussionMessage,
      join: c in Chatter, on: c.id == dm.chatter_id,
      distinct: true,
      select: {dm.discussion_id, c.nickname},
      where: dm.discussion_id in ^discussion_ids)
    |> OmniChat.Repo.all
    |> Enum.group_by(fn {id, _} -> id end)
  end

  def fetch_all_with_participants do
    discussions = Repo.all(__MODULE__)
    participants_per_id = __MODULE__.participant_nicknames_per_discussion(discussions)
    Enum.map(discussions, fn discussion ->
      participants = participants_per_id[discussion.id] || []
      participants = Enum.sort(participants)
      formatted = Enum.map(participants, fn {_, nickname} -> %{nickname: nickname} end)
      %{discussion | participants: formatted}
    end)
  end
end
