defmodule OmniChat.Chatter do
  use OmniChat.Web, :model

  require Logger

  schema "chatters" do
    field :phone_number, :string
    field :expire_at, Ecto.DateTime
    field :authentication_code, :string
    field :nickname, :string

    timestamps()
  end

  def authentication_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone_number, :nickname])
    |> validate_required([:phone_number])
    |> do_normalize_phone_number
    |> validate_length(:phone_number, is: 10, message: "should be %{count} numbers long")
    |> validate_format(:phone_number, ~r/NOPE/)
    |> generate_authentication_code
  end

  defp do_normalize_phone_number(changeset) do
    normalized_number = normalize_phone_number(changeset.changes.phone_number)
    put_change(changeset, :phone_number, normalized_number)
  end

  defp normalize_phone_number(number),
    do: Regex.replace(~r/\D+/, number, "")

  def authentication_message(chatter) do
    "#{chatter.authentication_code} is your OmniChat authentication code"
  end

  def with_phone_number(number) do
    normalized_number = normalize_phone_number(number)
    from c in "chatters", where: c.phone_number == ^normalized_number
  end

  defp generate_authentication_code(changeset) do
    code =
      1..6
      |> Enum.map(fn _ -> :rand.uniform(10) - 1 end)
      |> Enum.join

    put_change(changeset, :authentication_code, code)
  end
end
