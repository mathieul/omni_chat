defmodule OmniChat.Discussion do
  use OmniChat.Web, :model

  schema "discussions" do
    field :subject, :string

    has_many :discussion_messages, OmniChat.DiscussionMessage
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject])
    |> validate_required([:subject])
    |> unique_constraint(:subject)
  end
end
