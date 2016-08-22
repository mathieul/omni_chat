module Online.Types exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)
import Phoenix.Socket
import Json.Encode exposing (Value)
import Dom


-- Model


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , connected : Bool
    , presences : PresenceState
    , discussions : List Discussion
    , discussionId : Maybe DiscussionId
    , messages : List DiscussionMessage
    , config : AppConfig
    , route : Route
    , currentMessage : String
    , editingDiscussion : Bool
    , discussionSubject : String
    }



-- Route


type Route
    = DiscussionListRoute
    | DiscussionRoute DiscussionId
    | NotFoundRoute



-- Update


type alias AppConfig =
    { chatterId : ChatterId
    , nickname : String
    , maxMessages : Int
    , discussionId : Maybe DiscussionId
    , socketServer : String
    }


type Msg
    = NoOp
    | InitApplication
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | HandlePresenceState Value
    | HandlePresenceDiff Value
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveAllDiscussions Value
    | ReceiveMessageList Value
    | ReceiveMessage Value
    | UpdateCurrentMessage String
    | SendMessage
    | ShowDiscussionList
    | ShowDiscussion DiscussionId
    | StartEditingDiscussion
    | StopEditingDiscussion
    | UpdateDiscussionSubject String
    | CreateDiscussion String



-- Presence


type alias PresenceState =
    Dict String PresenceStateMetaWrapper


type alias PresenceStateMetaWrapper =
    { metas : List PresenceStateMetaValue }


type alias PresenceStateMetaValue =
    { phx_ref : String
    , online_at : String
    , nickname : String
    }



-- Discussion


type alias DiscussionId =
    Int


type alias Discussion =
    { id : DiscussionId
    , subject : String
    , participants : List Chatter
    , last_activity : String
    }


type alias ChatterId =
    Int


type alias Chatter =
    { id : ChatterId
    , nickname : String
    }


type alias DiscussionMessage =
    { chatter : Chatter
    , content : String
    , insertedAt : Date
    }
