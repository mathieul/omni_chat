# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OmniChat.Repo.insert!(%OmniChat.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias OmniChat.Repo
alias OmniChat.Discussion
alias OmniChat.DiscussionMessage
alias OmniChat.Chatter

zhanna =
  %Chatter{}
  |> Chatter.authentication_changeset(%{phone_number: "5109141524", nickname: "zhannulia"})
  |> Repo.insert!

ari =
  %Chatter{}
  |> Chatter.authentication_changeset(%{phone_number: "6508887766", nickname: "riri"})
  |> Repo.insert!

sophie =
  %Chatter{}
  |> Chatter.authentication_changeset(%{phone_number: "4156785544", nickname: "fifi"})
  |> Repo.insert!

mathieu =
  %Chatter{}
  |> Chatter.authentication_changeset(%{phone_number: "6504300629", nickname: "coukie"})
  |> Repo.insert!

discussion1 =
  %Discussion{}
  |> Discussion.changeset(%{subject: "how do you like Maui?"})
  |> Repo.insert!

discussion2 =
  %Discussion{}
  |> Discussion.changeset(%{subject: "what do we eat tonight?"})
  |> Repo.insert!

[ %{chatter_id: zhanna.id, content: "it looks pretty good from here"},
  %{chatter_id: sophie.id, content: "yes, I like it!"},
  %{chatter_id: ari.id, content: "where is the bart train?"},
  %{chatter_id: zhanna.id, content: "it's back home"} ]
|> Enum.each(fn params ->
      discussion1
      |> Ecto.build_assoc(:discussion_messages, params)
      |> Repo.insert!
   end)

[ %{chatter_id: mathieu.id, content: "what are we drinking?"},
  %{chatter_id: ari.id, content: "I'm not thirsty!"},
  %{chatter_id: sophie.id, content: "can I have wine?"},
  %{chatter_id: mathieu.id, content: "..."},
  %{chatter_id: sophie.id, content: "but I really want wine!"} ]
|> Enum.each(fn params ->
      discussion2
      |> Ecto.build_assoc(:discussion_messages, params)
      |> Repo.insert!
   end)
