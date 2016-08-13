defmodule OmniChat.Repo.Migrations.DeleteSubscriptions do
  use Ecto.Migration

  def change do
    drop table(:subscriptions)
  end
end
