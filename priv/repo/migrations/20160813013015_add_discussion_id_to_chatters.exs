defmodule OmniChat.Repo.Migrations.AddDiscussionIdToChatters do
  use Ecto.Migration

  def change do
    alter table(:chatters) do
      add :discussion_id, references(:discussions, on_delete: :nothing)
    end

    create index(:chatters, [:discussion_id])
  end
end
