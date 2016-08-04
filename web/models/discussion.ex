defmodule OmniChat.Discussion do
  use OmniChat.Web, :model

  alias OmniChat.DiscussionMessage
  alias OmniChat.Chatter
  alias OmniChat.Repo

  schema "discussions" do
    field :subject, :string
    field :participants, {:array, :string}, default: [], virtual: true
    field :last_activity_at, Timex.Ecto.DateTime, virtual: true

    has_many :discussion_messages, DiscussionMessage, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject])
    |> validate_required([:subject])
    |> unique_constraint(:subject)
  end

  def participants_per_discussion(discussions) do
    discussion_ids = Enum.map(discussions, &(&1.id))

    from(dm in DiscussionMessage,
      join: c in Chatter, on: c.id == dm.chatter_id,
      distinct: [dm.discussion_id, c.nickname],
      select: [dm.discussion_id, c.nickname, dm.inserted_at],
      where: dm.discussion_id in ^discussion_ids)
    |> OmniChat.Repo.all
    |> Enum.group_by(&List.first/1)
  end

  def fetch_all_with_participants do
    discussions = Repo.all(__MODULE__)
    participants_by_id = __MODULE__.participants_per_discussion(discussions)
    Enum.map(discussions, fn discussion ->
      items = participants_by_id[discussion.id]
      participants =
        items
        |> Enum.map(fn [_, nickname, _] -> nickname end)
        |> Enum.sort
        |> Enum.map(fn nickname -> %{nickname: nickname} end)
      last_activity_at =
        items
        |> Enum.map(fn [_, _, datetime] -> datetime end)
        |> Enum.sort
        |> List.last
      %{discussion | participants: participants, last_activity_at: last_activity_at}
    end)
  end
end
