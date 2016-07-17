defmodule OmniChat.ChatterTest do
  use OmniChat.ModelCase

  alias OmniChat.Chatter

  @valid_attrs %{authentication_code: "some content", expire_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, nickname: "some content", phone_number: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Chatter.changeset(%Chatter{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Chatter.changeset(%Chatter{}, @invalid_attrs)
    refute changeset.valid?
  end
end
