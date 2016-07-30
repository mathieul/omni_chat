defmodule OmniChat.Repo.Migrations.CreateDiscussionMessage do
  use Ecto.Migration

  def change do
    create table(:discussion_messages) do
      add :content, :text
      add :chatter_id, references(:chatters, on_delete: :nothing), null: false
      add :discussion_id, references(:discussions, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:discussion_messages, [:chatter_id])
    create index(:discussion_messages, [:discussion_id])

  end
end
