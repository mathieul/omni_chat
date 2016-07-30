defmodule OmniChat.DiscussionMessage do
  use OmniChat.Web, :model

  schema "discussion_messages" do
    field :content, :string

    belongs_to :chatter,    OmniChat.Chatter
    belongs_to :discussion, OmniChat.Discussion
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
