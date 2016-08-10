defmodule OmniChat.DiscussionMessage do
  use OmniChat.Web, :model

  @max_number_messages_fetched 50

  schema "discussion_messages" do
    field :content, :string

    belongs_to :chatter,    OmniChat.Chatter
    belongs_to :discussion, OmniChat.Discussion
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :chatter_id, :discussion_id])
    |> validate_required([:content, :chatter_id, :discussion_id])
  end

  def fetch_recent_messages(discussion_id) do
    from(dm in __MODULE__,
      preload: [:chatter],
      where: dm.discussion_id == ^discussion_id,
      order_by: [desc: dm.inserted_at],
      limit: @max_number_messages_fetched)
      |> OmniChat.Repo.all
      |> Enum.reverse
  end

  def max_messages do
    @max_number_messages_fetched
  end
end
