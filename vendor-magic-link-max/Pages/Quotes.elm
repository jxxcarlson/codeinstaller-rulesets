module Pages.Quotes exposing (..)

import Element exposing (Element)
import Html exposing (Html, text)
import Html.Attributes exposing (style)


view model =
    Html.div [ style "padding" "50px" ]
        [ Html.text "Here are some famous quotes:"
        , Html.text "\n\n(( Coming soon ...))"
        ]
        |> Element.html
