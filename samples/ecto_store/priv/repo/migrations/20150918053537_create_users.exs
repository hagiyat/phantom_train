defmodule SampleTrain.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_id, :string, null: false
      add :nickname, :string, null: false
      add :contact_id, :string

      timestamps
    end
  end
end
