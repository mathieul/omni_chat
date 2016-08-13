defmodule OmniChat.Chatter do
  use OmniChat.Web, :model

  require Logger

  schema "chatters" do
    field :phone_number, :string
    field :expire_at, Ecto.DateTime
    field :authentication_code, :string
    field :nickname, :string

    belongs_to :discussion, OmniChat.Discussion
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone_number, :nickname, :discussion_id])
    |> assoc_constraint(:discussion)
    |> pick_random_nickname
    |> validate_required([:nickname])
    |> unique_constraint(:nickname)
  end

  def authentication_changeset(struct, params) do
    changeset(struct, params)
    |> validate_required([:phone_number])
    |> do_normalize_phone_number
    |> validate_length(:phone_number, is: 10, message: "should be %{count} numbers long")
    |> unique_constraint(:phone_number)
    |> generate_authentication_code
  end

  def normalize_phone_number(number) do
    case Regex.replace(~r/\D+/, number, "") do
      "1" <> rest ->
        rest

      all ->
        all
    end
  end

  defp pick_random_nickname(changeset) do
    nickname = get_field(changeset, :nickname)

    if empty?(nickname) do
      nickname = Enum.join([String.downcase(Faker.Name.first_name), :rand.uniform(99)])
      put_change(changeset, :nickname, nickname)
    else
      changeset
    end
  end

  defp empty?(nil),
    do: true
  defp empty?(string) when is_binary(string),
    do: String.length(String.trim(string)) == 0

  defp do_normalize_phone_number(changeset) do
    normalized_number =
      changeset
      |> get_field(:phone_number)
      |> normalize_phone_number

    put_change(changeset, :phone_number, normalized_number)
  end

  def authentication_message(chatter) do
    "#{chatter.authentication_code} is your OmniChat authentication code"
  end

  def with_phone_number(number) do
    normalized_number = normalize_phone_number(number)
    from c in __MODULE__, where: c.phone_number == ^normalized_number, limit: 1
  end

  def for_discussion(discussion_id, except: chatter_ids) do
    from c in __MODULE__,
      where: c.discussion_id == ^discussion_id and not c.id in ^chatter_ids
  end

  defp generate_authentication_code(changeset) do
    code =
      1..6
      |> Enum.map(fn _ -> :rand.uniform(10) - 1 end)
      |> Enum.join

    put_change(changeset, :authentication_code, code)
  end
end
