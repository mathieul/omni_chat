module Online.Routing exposing (..)

import String
import Navigation
import UrlParser exposing ((</>))


-- exposing (..)

import Online.Types exposing (DiscussionId)


type Route
    = DiscussionsRoute
    | DiscussionRoute DiscussionId
    | NotFoundRoute


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.format DiscussionsRoute (UrlParser.s "")
        , UrlParser.format DiscussionRoute (UrlParser.s "discussions" </> UrlParser.int)
        , UrlParser.format DiscussionsRoute (UrlParser.s "discussions")
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
