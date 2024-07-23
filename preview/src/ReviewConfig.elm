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



config = RuleSet.Add.configMagicLinkAuth "Jim Carlson" "jxxcarlson" "jxxcarlson@gmail.com"


--configMagicLinkAuth fullname username email =
--    configAll {fullname = fullname, username = username, email = email }
