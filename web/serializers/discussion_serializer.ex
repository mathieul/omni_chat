defmodule OmniChat.DiscussionSerializer do
  use JaSerializer
  use Timex

  attributes [:subject, :participants, :last_activity]

  def last_activity(discussion, _conn) do
    Timex.from_now(discussion.last_activity_at)
  end
end
