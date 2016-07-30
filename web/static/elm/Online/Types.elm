module Online.Types exposing (..)

import Phoenix.Socket
import Json.Encode exposing (Value)
import Dict exposing (Dict)


type alias PresenceState =
    Dict String PresenceStateMetaWrapper


type alias PresenceStateMetaWrapper =
    { metas : List PresenceStateMetaValue }


type alias PresenceStateMetaValue =
    { phx_ref : String
    , online_at : String
    , nickname : String
    , phone_number : String
    }


type alias PresenceDiff =
    { leaves : PresenceState
    , joins : PresenceState
    }


type alias ApplicationConfig =
    { chatter_id : Int
    , nickname : String
    , phone_number : String
    }


type Msg
    = InitApplication ApplicationConfig
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveChatMessage Value
    | HandlePresenceState Value
    | HandlePresenceDiff Value
