defmodule OmniChat.DiscussionSerializer do
  use JaSerializer
  use Timex

  attributes [:subject, :participants, :last_activity]

  def last_activity(discussion, _conn) do
    last_activity =
      Timex.now
      |> Timex.diff(discussion.last_activity_at, :minutes)
      |> Duration.from_minutes
      |> Timex.format_duration(:humanized)

    case last_activity do
      "" ->
        "just now"
      time_ago ->
        "#{time_ago} ago"
    end
  end
end
