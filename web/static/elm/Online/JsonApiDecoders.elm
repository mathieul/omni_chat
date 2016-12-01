module Online.JsonApiDecoders
    exposing
        ( decodeDiscussionCollection
        , decodeDiscussionMessageCollection
        , decodeDiscussionMessage
        )

import Date
import Json.Decode as JD exposing (field)
import Json.Decode.Extra as JDE
import Json.Encode as JE
import JsonApi
import JsonApi.Documents
import JsonApi.Decode
import JsonApi.Resources
import Online.Types exposing (Model, Discussion, DiscussionMessage, Chatter)


decodeDiscussionCollection : JE.Value -> Model -> Model
decodeDiscussionCollection raw model =
    let
        discussions =
            JD.decodeValue JsonApi.Decode.document raw
                |> Result.andThen JsonApi.Documents.primaryResourceCollection
                |> Result.map (List.map extractDiscussionFromResource)
                |> Result.withDefault []
    in
        { model | discussions = discussions }


decodeDiscussionMessageCollection : JE.Value -> Model -> Model
decodeDiscussionMessageCollection raw model =
    let
        messages =
            JD.decodeValue JsonApi.Decode.document raw
                |> Result.andThen JsonApi.Documents.primaryResourceCollection
                |> Result.map (List.map extractMessageFromResource)
                |> Result.withDefault []
    in
        { model | messages = messages }


decodeDiscussionMessage : JE.Value -> Model -> Model
decodeDiscussionMessage raw model =
    let
        messages =
            model.messages
                |> List.reverse
                |> List.take (model.config.maxMessages - 1)
                |> (::) (extractMessage raw)
                |> List.reverse
    in
        { model | messages = messages }


extractDiscussionFromResource : JsonApi.Resource -> Discussion
extractDiscussionFromResource discussionResource =
    case JsonApi.Resources.attributes discussionDecoder discussionResource of
        Ok discussion ->
            discussion

        Err error ->
            Debug.crash error


extractMessage : JE.Value -> DiscussionMessage
extractMessage raw =
    let
        messageResult =
            JD.decodeValue JsonApi.Decode.document raw
                |> Result.andThen JsonApi.Documents.primaryResource
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
                |> JsonApi.Resources.attributes (field "content" JD.string)
                |> Result.withDefault ""

        insertedAt =
            messageResource
                |> JsonApi.Resources.attributes (field "inserted-at" JDE.date)
                |> Result.withDefault (Date.fromTime 0)

        chatterResult =
            JsonApi.Resources.relatedResource "chatter" messageResource
                |> Result.andThen (JsonApi.Resources.attributes chatterDecoder)

        chatter =
            case chatterResult of
                Ok chatter ->
                    chatter

                Err error ->
                    Debug.crash error
    in
        DiscussionMessage chatter content insertedAt


discussionDecoder : JD.Decoder Discussion
discussionDecoder =
    JD.map4 Discussion
        (field "id" JD.int)
        (field "subject" JD.string)
        (field "participants" (JD.list chatterDecoder))
        (field "last-activity" JD.string)


chatterDecoder : JD.Decoder Chatter
chatterDecoder =
    JD.map2 Chatter
        (field "id" JD.int)
        (field "nickname" JD.string)
