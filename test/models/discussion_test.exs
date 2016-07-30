defmodule OmniChat.DiscussionTest do
  use OmniChat.ModelCase

  alias OmniChat.Discussion

  @valid_attrs %{subject: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Discussion.changeset(%Discussion{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Discussion.changeset(%Discussion{}, @invalid_attrs)
    refute changeset.valid?
  end
end
