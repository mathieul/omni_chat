defmodule OmniChat.Repo.Migrations.CreateDiscussion do
  use Ecto.Migration

  def change do
    create table(:discussions) do
      add :subject, :string, null: false

      timestamps()
    end
    create unique_index(:discussions, [:subject])

  end
end
