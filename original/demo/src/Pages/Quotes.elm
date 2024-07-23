module Pages.Quotes exposing(view)

import Element exposing (Element)
import Types exposing (FrontendMsg(..), LoadedModel)


view : LoadedModel -> Element FrontendMsg
view model =
    Element.column [ Element.paddingXY 0 30, Element.spacing 12 ]
        [ Element.column [] [ Element.text "A list of quotes ... coming soon!" ]
        ]
