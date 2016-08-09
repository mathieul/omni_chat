module Online.Types exposing (..)

import Dict exposing (Dict)
import Phoenix.Socket
import Json.Encode exposing (Value)
import Components.DiscussionEditor as DiscussionEditor


-- Update


type alias AppConfig =
    { chatter_id : Int
    , nickname : String
    }


type Msg
    = InitApplication AppConfig
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | HandlePresenceState Value
    | HandlePresenceDiff Value
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveAllDiscussions Value
    | ReceiveMessages Value
    | DiscussionEditorMsg DiscussionEditor.Msg
    | ShowDiscussionsList
    | ShowDiscussion DiscussionId



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
    }
