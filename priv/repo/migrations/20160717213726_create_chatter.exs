defmodule OmniChat.Repo.Migrations.CreateChatter do
  use Ecto.Migration

  def change do
    create table(:chatters) do
      add :phone_number,        :string,    null: false
      add :expire_at,           :datetime,  null: false, default: fragment("(now() at time zone 'UTC' + interval '15 minutes')")
      add :authentication_code, :string,    null: false
      add :nickname,            :string,    null: false

      timestamps()
    end

    create unique_index(:chatters, [:phone_number])
    create unique_index(:chatters, [:nickname])
    create index(:chatters, [:authentication_code])
  end
end
