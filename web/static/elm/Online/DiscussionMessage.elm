module Online.DiscussionMessage exposing (receiveCollection)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Model exposing (Model)
import Online.Types exposing (Msg, DiscussionMessage, Chatter)


type alias JsonApiContainer =
    { data : List AllMessagesWrapper }


type alias AllMessagesWrapper =
    { attributes : DiscussionMessage }


receiveCollection : JE.Value -> Model -> ( Model, Cmd Msg )
receiveCollection raw model =
    case JD.decodeValue collectionDecoder raw of
        Ok content ->
            let
                _ =
                    Debug.log "DiscussionMessage Content: " content

                messages =
                    List.map (\item -> item.attributes) content.data
            in
                { model | messages = messages } ! []

        Err error ->
            let
                _ =
                    Debug.log "DiscussionMessage Error: " error
            in
                model ! []


collectionDecoder : JD.Decoder JsonApiContainer
collectionDecoder =
    JD.object1 JsonApiContainer
        ("data" := JD.list attributesDecoder)


attributesDecoder : JD.Decoder AllMessagesWrapper
attributesDecoder =
    JD.object1 AllMessagesWrapper
        ("attributes" := discussionDecoder)


discussionDecoder : JD.Decoder DiscussionMessage
discussionDecoder =
    JD.object2 DiscussionMessage
        ("chatter" := chatterDecoder)
        ("content" := JD.string)


chatterDecoder : JD.Decoder Chatter
chatterDecoder =
    JD.object2 Chatter
        ("id" := JD.int)
        ("nickname" := JD.string)
