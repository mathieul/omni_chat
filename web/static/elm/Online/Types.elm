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
    | DiscussionEditorMsg DiscussionEditor.Msg



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


type alias Discussion =
    { subject : String
    , participants : List Participant
    , last_activity_at : String
    }


type alias Participant =
    { nickname : String }
