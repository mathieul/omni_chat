defmodule OmniChat.DiscussionMessageSerializer do
  use JaSerializer

  attributes [:content, :inserted_at]
  has_one :chatter,
    serializer: OmniChat.ChatterSerializer,
    include: true
end
