module Online.DiscussionMessage exposing (decodeCollection, decodeOne)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import JsonApi
import JsonApi.Documents
import JsonApi.Decode
import JsonApi.Resources
import Online.Types exposing (Model, DiscussionMessage, Chatter)


decodeCollection : JE.Value -> Model -> Model
decodeCollection raw model =
    let
        messages =
            JD.decodeValue JsonApi.Decode.document raw
                |> (flip Result.andThen) JsonApi.Documents.primaryResourceCollection
                |> Result.map (List.map extractMessageFromResource)
                |> Result.withDefault []
    in
        { model | messages = messages }


decodeOne : JE.Value -> Model -> Model
decodeOne raw model =
    let
        messages =
            model.messages
                |> List.reverse
                |> List.take (model.config.maxMessages - 1)
                |> (::) (extractMessage raw)
                |> List.reverse
    in
        { model | messages = messages }


extractMessage : JE.Value -> DiscussionMessage
extractMessage raw =
    let
        messageResult =
            JD.decodeValue JsonApi.Decode.document raw
                |> (flip Result.andThen) JsonApi.Documents.primaryResource
                |> Result.map extractMessageFromResource
    in
        case messageResult of
            Ok message ->
                message

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
    let
        chatterResult =
            JsonApi.Resources.relatedResource "chatter" messageResource
                |> (flip Result.andThen) (JsonApi.Resources.attributes chatterDecoder)
    in
        case chatterResult of
            Ok chatter ->
                chatter

            Err error ->
                Debug.crash error


chatterDecoder : JD.Decoder Chatter
chatterDecoder =
    JD.object2 Chatter
        ("id" := JD.int)
        ("nickname" := JD.string)
