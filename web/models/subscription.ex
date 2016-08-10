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

  def by_chatter_and_discussion(%{chatter_id: chatter_id, discussion_id: discussion_id}) do
    from s in __MODULE__,
      where: s.chatter_id == ^chatter_id,
      where: s.discussion_id == ^discussion_id
  end
end
