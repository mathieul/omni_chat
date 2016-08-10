defmodule OmniChat.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :discussion_id, references(:discussions, on_delete: :nothing)
      add :chatter_id, references(:chatters, on_delete: :nothing)

      timestamps()
    end
    create index(:subscriptions, [:discussion_id])
    create index(:subscriptions, [:chatter_id])

  end
end
