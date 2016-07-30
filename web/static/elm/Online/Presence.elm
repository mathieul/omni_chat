module Online.Presence exposing (processPresenceState, processPresenceDiff)

import Dict
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Types
    exposing
        ( Msg
        , PresenceState
        , PresenceStateMetaWrapper
        , PresenceStateMetaValue
        )
import Online.Model exposing (Model)


type alias PresenceDiff =
    { leaves : PresenceState
    , joins : PresenceState
    }


processPresenceState : JE.Value -> Model -> ( Model, Cmd Msg )
processPresenceState raw model =
    case JD.decodeValue presenceStateDecoder raw of
        Ok presenceState ->
            { model | presences = presenceState } ! []

        Err error ->
            model ! []


processPresenceDiff : JE.Value -> Model -> ( Model, Cmd Msg )
processPresenceDiff raw model =
    case JD.decodeValue presenceDiffDecoder raw of
        Ok presenceDiff ->
            let
                _ =
                    Debug.log "PRESENCE_DIFF" presenceDiff

                presencesAfterDel =
                    presenceDiff.leaves
                        |> Dict.keys
                        |> List.foldl Dict.remove model.presences

                insertPresence id presences =
                    case Dict.get id presenceDiff.joins of
                        Just value ->
                            Dict.insert id value presences

                        Nothing ->
                            presences

                presencesAfterAdd =
                    presenceDiff.joins
                        |> Dict.keys
                        |> List.foldl insertPresence presencesAfterDel
            in
                { model | presences = presencesAfterAdd } ! []

        Err error ->
            model ! []


presenceDiffDecoder : JD.Decoder PresenceDiff
presenceDiffDecoder =
    JD.object2 PresenceDiff
        ("leaves" := presenceStateDecoder)
        ("joins" := presenceStateDecoder)


presenceStateDecoder : JD.Decoder PresenceState
presenceStateDecoder =
    JD.dict presenceStateMetaWrapperDecoder


presenceStateMetaWrapperDecoder : JD.Decoder PresenceStateMetaWrapper
presenceStateMetaWrapperDecoder =
    JD.object1 PresenceStateMetaWrapper
        ("metas" := JD.list presenceStateMetaDecoder)


presenceStateMetaDecoder : JD.Decoder PresenceStateMetaValue
presenceStateMetaDecoder =
    JD.object3 PresenceStateMetaValue
        ("phx_ref" := JD.string)
        ("online_at" := JD.string)
        ("nickname" := JD.string)
