module Online.Discussion exposing (decodeCollection)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import JsonApi
import JsonApi.Documents
import JsonApi.Decode
import JsonApi.Resources
import Online.Types exposing (Model, Msg, Discussion, Chatter)


decodeCollection : JE.Value -> Model -> Model
decodeCollection raw model =
    let
        discussions =
            JD.decodeValue JsonApi.Decode.document raw
                |> (flip Result.andThen) JsonApi.Documents.primaryResourceCollection
                |> Result.map (List.map extractDiscussionFromResource)
                |> Result.withDefault []
    in
        { model | discussions = discussions }


extractDiscussionFromResource : JsonApi.Resource -> Discussion
extractDiscussionFromResource discussionResource =
    case JsonApi.Resources.attributes discussionDecoder discussionResource of
        Ok discussion ->
            discussion

        Err error ->
            Debug.crash error


discussionDecoder : JD.Decoder Discussion
discussionDecoder =
    JD.object4 Discussion
        ("id" := JD.int)
        ("subject" := JD.string)
        ("participants" := JD.list chatterDecoder)
        ("last-activity" := JD.string)


chatterDecoder : JD.Decoder Chatter
chatterDecoder =
    JD.object2 Chatter
        ("id" := JD.int)
        ("nickname" := JD.string)
