module Pages.Notes exposing (..)

import Element exposing (Element)
import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Types exposing (FrontendMsg(..), LoadedModel)


view model =
    Html.div [ style "padding" "50px" ]
        [ Html.text "This app is a demo of a very simple single-page application in Elm."
        , Html.text "\n\nWe are working on elm-review code to add new pages."
        ]
        |> Element.html
