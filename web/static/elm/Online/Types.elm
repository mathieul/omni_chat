module Online.Types exposing (..)

import Dict exposing (Dict)
import Phoenix.Socket
import Json.Encode exposing (Value)


-- Update


type alias AppConfig =
    { chatter_id : Int
    , nickname : String
    }


type Msg
    = InitApplication AppConfig
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveChatMessage Value
    | HandlePresenceState Value
    | HandlePresenceDiff Value



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
