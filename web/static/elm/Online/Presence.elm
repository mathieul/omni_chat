module Online.Presence exposing (processPresenceState, processPresenceDiff)

import Dict
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Online.Types
    exposing
        ( Model
        , Msg
        , PresenceState
        , PresenceStateMetaWrapper
        , PresenceStateMetaValue
        )


type alias PresenceDiff =
    { leaves : PresenceState
    , joins : PresenceState
    }


processPresenceState : JE.Value -> Model -> Model
processPresenceState raw model =
    case JD.decodeValue presenceStateDecoder raw of
        Ok presenceState ->
            { model | presences = presenceState }

        Err error ->
            model


processPresenceDiff : JE.Value -> Model -> Model
processPresenceDiff raw model =
    case JD.decodeValue presenceDiffDecoder raw of
        Ok presenceDiff ->
            let
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
                { model | presences = presencesAfterAdd }

        Err error ->
            model


presenceDiffDecoder : JD.Decoder PresenceDiff
presenceDiffDecoder =
    JD.map2 PresenceDiff
        (field "leaves" presenceStateDecoder)
        (field "joins" presenceStateDecoder)


presenceStateDecoder : JD.Decoder PresenceState
presenceStateDecoder =
    JD.dict presenceStateMetaWrapperDecoder


presenceStateMetaWrapperDecoder : JD.Decoder PresenceStateMetaWrapper
presenceStateMetaWrapperDecoder =
    JD.map PresenceStateMetaWrapper
        (field "metas" (JD.list presenceStateMetaDecoder))


presenceStateMetaDecoder : JD.Decoder PresenceStateMetaValue
presenceStateMetaDecoder =
    JD.map3 PresenceStateMetaValue
        (field "phx_ref" JD.string)
        (field "online_at" JD.string)
        (field "nickname" JD.string)
