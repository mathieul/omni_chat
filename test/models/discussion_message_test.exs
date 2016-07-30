defmodule OmniChat.DiscussionMessageTest do
  use OmniChat.ModelCase

  alias OmniChat.DiscussionMessage

  @valid_attrs %{content: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DiscussionMessage.changeset(%DiscussionMessage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DiscussionMessage.changeset(%DiscussionMessage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
