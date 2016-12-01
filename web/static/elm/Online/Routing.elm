module Online.Routing exposing (matchers, parseLocation)

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), oneOf, s, int)
import Online.Types exposing (DiscussionId, Route(..))


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ UrlParser.map DiscussionListRoute (s "")
        , UrlParser.map DiscussionRoute (s "discussions" </> int)
        , UrlParser.map DiscussionListRoute (s "discussions")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (UrlParser.parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
