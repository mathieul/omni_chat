defmodule OmniChat.DiscussionSerializer do
  use JaSerializer

  attributes [:subject, :participants, :last_activity_at]

  def last_activity_at(discussion, _conn) do
    Timex.format!(discussion.last_activity_at, "%F %I:%M%P", :strftime)
  end
end
