module Online.DiscussionMessage exposing (receiveCollection, receiveOne)

import Dict exposing (Dict)
import Json.Decode as JD exposing ((:=))
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
                |> List.take (model.config.maxMessages - 1)
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
        content =
            messageResource
                |> JsonApi.Resources.attributes ("content" := JD.string)
                |> Result.withDefault ""
    in
        { chatter = extractChatterAsRelatedResource messageResource
        , content = content
        }


extractChatterAsRelatedResource : JsonApi.Resource -> Chatter
extractChatterAsRelatedResource messageResource =
    case JsonApi.Resources.relatedResource "chatter" messageResource of
        Ok chatterValue ->
            case JsonApi.Resources.attributes chatterDecoder chatterValue of
                Ok chatter ->
                    chatter

                Err error ->
                    Debug.crash error

        Err error ->
            Debug.crash error


chatterDecoder : JD.Decoder Chatter
chatterDecoder =
    JD.object2 Chatter
        ("id" := JD.int)
        ("nickname" := JD.string)
