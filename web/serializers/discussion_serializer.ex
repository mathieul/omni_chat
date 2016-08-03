defmodule OmniChat.DiscussionSerializer do
  use JaSerializer

  attributes [:subject, :participants, :last_activity_at]

  def participants(_discussion, _conn) do
    [%{"nickname" => "mathieu"}, %{"nickname" => "zlaj"}]
  end

  def last_activity_at(discussion, _conn) do
    # TODO: make last activity discussion_messages.last.inserted_at
    Timex.format!(discussion.updated_at, "%F %I:%M%P", :strftime)
  end
end
