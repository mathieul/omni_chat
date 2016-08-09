module Online.Routing exposing (..)

import String
import Navigation
import UrlParser exposing ((</>))
import Online.Types exposing (DiscussionId, Route(..))


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.format DiscussionListRoute (UrlParser.s "")
        , UrlParser.format DiscussionRoute (UrlParser.s "discussions" </> UrlParser.int)
        , UrlParser.format DiscussionListRoute (UrlParser.s "discussions")
        ]


hashParser : Navigation.Location -> Result String Route
hashParser location =
    location.hash
        |> String.dropLeft 1
        |> UrlParser.parse identity matchers


parser : Navigation.Parser (Result String Route)
parser =
    Navigation.makeParser hashParser


routeFromResult : Result String Route -> Route
routeFromResult result =
    case result of
        Ok route ->
            route

        Err string ->
            NotFoundRoute
