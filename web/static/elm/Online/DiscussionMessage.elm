module Online.DiscussionMessage exposing (receiveCollection, receiveStuff)

import JsonApi.Documents
import JsonApi.Decode
import JsonApi.Resources
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Model exposing (Model)
import Online.Types exposing (Msg, DiscussionMessage, Chatter)


receiveStuff : JE.Value -> Model -> ( Model, Cmd Msg )
receiveStuff raw model =
    case JD.decodeValue JsonApi.Decode.document raw of
        Ok document ->
            let
                processed =
                    case JsonApi.Documents.primaryResourceCollection document of
                        Ok resourceList ->
                            case List.head resourceList of
                                Nothing ->
                                    Debug.crash "Expected non-empty collection"

                                Just resource ->
                                    case JsonApi.Resources.relatedResource "chatter" resource of
                                        Ok found ->
                                            Debug.log "FOUND>>>" (JsonApi.Resources.attributes found)

                                        Err message ->
                                            Debug.crash message

                        Err message ->
                            Debug.crash message

                _ =
                    Debug.log "JsonApi.Document" processed
            in
                model ! []

        Err error ->
            model ! []


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
