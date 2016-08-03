module Online.Discussion exposing (receiveAll)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Model exposing (Model)
import Online.Types exposing (Msg, Discussion, Participant)


type alias JsonApiContainer =
    { data : List AllDiscussionsWrapper }


type alias AllDiscussionsWrapper =
    { attributes : Discussion }


receiveAll : JE.Value -> Model -> ( Model, Cmd Msg )
receiveAll raw model =
    case JD.decodeValue collectionDecoder raw of
        Ok content ->
            let
                _ =
                    Debug.log "CONTENT: " content

                discussions =
                    List.map (\item -> item.attributes) content.data
            in
                { model | discussions = discussions } ! []

        Err error ->
            let
                _ =
                    Debug.log "ERROR: " error
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
    JD.object3 Discussion
        ("subject" := JD.string)
        ("participants" := JD.list participantDecoder)
        ("last-activity-at" := JD.string)


participantDecoder : JD.Decoder Participant
participantDecoder =
    JD.object1 Participant
        ("nickname" := JD.string)
