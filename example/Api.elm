module Api exposing (routes)

{-| An example for elm-pages, you can drop this in your Api.elm file.
-}

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import BackendTask.Helpers exposing (..)
import BackendTask.Time
import Element
import FatalError exposing (FatalError)
import Head
import Html exposing (..)
import Html.Attributes
import Htmx
import Pages.Manifest as Manifest
import Route exposing (Route)
import Site
import Sitemap
import Time


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ Site.manifest |> Manifest.generator Site.config.canonicalUrl
    , apiExample htmlToString
    , apiTime htmlToString
    ]


apiTime =
    htmlRouteWithNow "api/time.html"
        (\now ->
            p (now |> Time.posixToMillis |> String.fromInt)
        )


apiExample =
    htmlRouteWithNow "api/example.html"
        (\now ->
            html
                [ head
                    [ title "Elm + HTMX!"
                    , script "https://unpkg.com/htmx.org@1.9.12"
                    ]
                , body []
                    [ div
                        [ Htmx.get "/api/time.html"
                        , Htmx.trigger "load, every 1s"
                        ]
                        [ p (now |> Time.posixToMillis |> String.fromInt) ]
                    ]
                ]
        )



-- Helpers


html contents =
    Html.node "html" [] contents


head contents =
    Html.node "head" [] contents


body attrs contents =
    Html.node "body" attrs contents


title text =
    Html.node "title" [] [ Html.text text ]


style text =
    Html.node "style" [] [ Html.text text ]


p text =
    Html.node "p" [] [ Html.text text ]


{-| Relies on toHtmlWithScripts to work
-}
script src =
    Html.node "js" [ Html.Attributes.src src ] []


route path task =
    ApiRoute.succeed task
        |> ApiRoute.literal path
        |> ApiRoute.single


routeWithNow path taskFn =
    ApiRoute.succeed
        (BackendTask.Time.now
            |> BackendTask.andThen
                taskFn
        )
        |> ApiRoute.literal path
        |> ApiRoute.single


toHtmlWithScripts htmlToString html_ =
    htmlToString Nothing html_
        |> String.replace "<js " "<script "
        |> String.replace "<js>" "<script>"
        |> String.replace "</js>" "</script>"


htmlRoute path htmlToString htmlTask =
    ApiRoute.succeed
        (htmlTask
            |> BackendTask.map (toHtmlWithScripts htmlToString)
        )
        |> ApiRoute.literal path
        |> ApiRoute.single


htmlRouteWithNow :
    String
    -> (Time.Posix -> Html Never)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> ApiRoute ApiRoute.Response
htmlRouteWithNow path taskFn htmlToString =
    ApiRoute.succeed
        (BackendTask.Time.now
            |> BackendTask.map taskFn
            |> BackendTask.map (toHtmlWithScripts htmlToString)
        )
        |> ApiRoute.literal path
        |> ApiRoute.single
