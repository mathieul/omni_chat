module Online.Discussion exposing (receiveAll)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Model exposing (Model)
import Online.Types exposing (Msg, Discussion, Participant)


type alias AllDiscussionsWrapper =
    { discussions : List Discussion }


receiveAll : JE.Value -> Model -> ( Model, Cmd Msg )
receiveAll raw model =
    case JD.decodeValue collectionDecoder raw of
        Ok content ->
            let
                _ =
                    Debug.log "CONTENT: " content
            in
                { model | discussions = content.discussions } ! []

        Err error ->
            let
                _ =
                    Debug.log "ERROR: " error
            in
                model ! []


collectionDecoder : JD.Decoder AllDiscussionsWrapper
collectionDecoder =
    JD.object1 AllDiscussionsWrapper
        ("discussions" := JD.list discussionDecoder)


discussionDecoder : JD.Decoder Discussion
discussionDecoder =
    JD.object3 Discussion
        ("subject" := JD.string)
        ("participants" := JD.list participantDecoder)
        ("last_activity_at" := JD.string)


participantDecoder : JD.Decoder Participant
participantDecoder =
    JD.object1 Participant
        ("nickname" := JD.string)
