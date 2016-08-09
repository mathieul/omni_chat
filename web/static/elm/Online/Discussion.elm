module Online.Discussion exposing (receiveAll)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Types exposing (Model, Msg, Discussion, Chatter)


type alias JsonApiContainer =
    { data : List AllDiscussionsWrapper }


type alias AllDiscussionsWrapper =
    { attributes : Discussion }


receiveAll : JE.Value -> Model -> ( Model, Cmd Msg )
receiveAll raw model =
    case JD.decodeValue collectionDecoder raw of
        Ok content ->
            let
                discussions =
                    List.map (\item -> item.attributes) content.data
            in
                { model | discussions = discussions } ! []

        Err error ->
            let
                _ =
                    Debug.log "Discussion Error: " error
            in
                model ! []


collectionDecoder : JD.Decoder JsonApiContainer
collectionDecoder =
    JD.object1 JsonApiContainer
        ("data" := JD.list attributesDecoder)


attributesDecoder : JD.Decoder AllDiscussionsWrapper
attributesDecoder =
    JD.object1 AllDiscussionsWrapper
        ("attributes" := discussionDecoder)


discussionDecoder : JD.Decoder Discussion
discussionDecoder =
    JD.object4 Discussion
        ("id" := JD.int)
        ("subject" := JD.string)
        ("participants" := JD.list participantDecoder)
        ("last-activity" := JD.string)


participantDecoder : JD.Decoder Chatter
participantDecoder =
    JD.object2 Chatter
        ("id" := JD.int)
        ("nickname" := JD.string)
