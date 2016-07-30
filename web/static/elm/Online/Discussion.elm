module Online.Discussion exposing (receiveAll)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Online.Model exposing (Model)
import Online.Types exposing (Msg, Discussion, Participant)


receiveAll : JE.Value -> Model -> ( Model, Cmd Msg )
receiveAll raw model =
    case JD.decodeValue collectionDecoder raw of
        Ok content ->
            model ! []

        Err error ->
            model ! []


collectionDecoder : JD.Decoder (List Discussion)
collectionDecoder =
    JD.list discussionDecoder


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
