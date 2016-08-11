defmodule OmniChat.Subscription do
  use OmniChat.Web, :model

  schema "subscriptions" do
    belongs_to :discussion, OmniChat.Discussion
    belongs_to :chatter, OmniChat.Chatter

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:discussion_id, :chatter_id])
    |> validate_required([:discussion_id, :chatter_id])
  end

  def find_by_discussion_and_chatter(%{discussion_id: discussion_id, chatter_id: chatter_id}) do
    from s in __MODULE__,
      where: [discussion_id: ^discussion_id, chatter_id: ^chatter_id]
  end

  def find_by_discussion_not_those_chatters(%{discussion_id: discussion_id, chatter_ids: chatter_ids}) do
    from s in __MODULE__,
    where: s.discussion_id == ^discussion_id and not s.chatter_id in ^chatter_ids
  end
end
