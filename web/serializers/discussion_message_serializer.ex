defmodule OmniChat.DiscussionMessageSerializer do
  use JaSerializer

  attributes [:content]
  has_one :chatter,
    serializer: OmniChat.ChatterSerializer,
    include: true
end
