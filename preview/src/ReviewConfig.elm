module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}


import RuleSet.Add
import Review.Rule exposing (Rule)
import String.Extra



{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}



config : List Rule
config  = pagesConfig

magicLinkConfig = RuleSet.Add.magicLinkAuth "Jim Carlson" "jxxcarlson" "jxxcarlson@gmail.com"

pagesConfig = RuleSet.Add.pages [ ("Quotes", "quotes"), ("Jokes", "jokes") ]

