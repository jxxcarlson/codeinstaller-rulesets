module ReviewConfig exposing (config)


{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Review.Rule exposing (Rule)
import RuleSest.Add

config : List Rule
config  = config1

config1 = RuleSet.Add.magicLinkAuth "Jim Carlson" "jxxcarlson" "jxxcarlson@gmail.com"

config2 = RuleSet.Add.pages [ ("QuotesRoute", "quotes"), ("QuotesRoute", "jokes") ]

