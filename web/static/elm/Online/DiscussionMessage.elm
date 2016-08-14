module Online.DiscussionMessage exposing (receiveCollection, receiveOne)

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import JsonApi
import JsonApi.Documents
import JsonApi.Decode
import JsonApi.Resources
import Online.Types exposing (Model, DiscussionMessage, Chatter)


receiveCollection : JE.Value -> Model -> Model
receiveCollection raw model =
    { model | messages = extractMessageCollectionFromJson raw }


receiveOne : JE.Value -> Model -> Model
receiveOne raw model =
    let
        messages =
            model.messages
                |> List.reverse
                |> List.take (model.config.max_messages - 1)
                |> (::) (extractMessageFromJson raw)
                |> List.reverse
    in
        { model | messages = messages }


extractMessageCollectionFromJson : JE.Value -> List DiscussionMessage
extractMessageCollectionFromJson raw =
    case JD.decodeValue JsonApi.Decode.document raw of
        Ok document ->
            extractMessageCollectionFromDocument document

        Err error ->
            Debug.crash error


extractMessageCollectionFromDocument : JsonApi.Document -> List DiscussionMessage
extractMessageCollectionFromDocument document =
    case JsonApi.Documents.primaryResourceCollection document of
        Ok resourceList ->
            List.map extractMessageFromResource resourceList

        Err error ->
            Debug.crash error


extractMessageFromJson : JE.Value -> DiscussionMessage
extractMessageFromJson raw =
    case JD.decodeValue JsonApi.Decode.document raw of
        Ok document ->
            extractMessageFromDocument document

        Err error ->
            Debug.crash error


extractMessageFromDocument : JsonApi.Document -> DiscussionMessage
extractMessageFromDocument document =
    case JsonApi.Documents.primaryResource document of
        Ok resource ->
            extractMessageFromResource resource

        Err error ->
            Debug.crash error


extractMessageFromResource : JsonApi.Resource -> DiscussionMessage
extractMessageFromResource messageResource =
    let
        attributes =
            JsonApi.Resources.attributes messageResource
    in
        { chatter = extractChatterAsRelatedResource messageResource
        , content = getStringAttribute "content" attributes
        }


extractChatterAsRelatedResource : JsonApi.Resource -> Chatter
extractChatterAsRelatedResource messageResource =
    let
        attributes =
            case JsonApi.Resources.relatedResource "chatter" messageResource of
                Ok chatter ->
                    JsonApi.Resources.attributes chatter

                Err error ->
                    Debug.crash error
    in
        { id = getIntAttribute "id" attributes
        , nickname = getStringAttribute "nickname" attributes
        }


getStringAttribute : String -> Dict String JD.Value -> String
getStringAttribute key dict =
    Dict.get key dict
        `Maybe.andThen` (JD.decodeValue JD.string >> Result.toMaybe)
        |> Maybe.withDefault "???"


getIntAttribute : String -> Dict String JD.Value -> Int
getIntAttribute key dict =
    Dict.get key dict
        `Maybe.andThen` (JD.decodeValue JD.int >> Result.toMaybe)
        |> Maybe.withDefault 0
