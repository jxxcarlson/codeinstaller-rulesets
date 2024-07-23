# Code installer rule sets

See the [Discourse article](https://discourse.elm-lang.org/t/installing-new-features-in-old-apps/9898).

Rule sets for adding code to existing projects:

        RuleSet.Add.pages [ ("Quotes", "quotes"), ("Jokes", "jokes") ] 
        -- [(route name, roude path),...]
        -- add pages to app

        RuleSet.Add.magicLinkAuth "Jane Doe" "jane" "jane@gmail.com"
        -- add magic link authentication to app with "jane" as the admin and first user

        RuleSet.Add.magicLinkAuthWiring
        -- add wiring only for magiclink authentication to app
        -- (COMING SOON)

Configure these for demo purposes in preview/src/ReviewConfig.elm, e.g.,

        config = pagesConfig

where

        magicLinkConfig = RuleSet.Add.magicLinkAuth "Jim Carlson" "jxxcarlson" "jxxcarlson@gmail.com"

        pagesConfig = RuleSet.Add.pages [ ("QuotesRoute", "quotes"), ("QuotesRoute", "jokes") ]


Then run  `make app` to apply the rule set." To restore the app to its original "base" state, run `make base`.

The app in `demo/` is a Lamdera app.  To run it, `cd` to that directory and say `lamdera live`.  The app will be available at `http://localhost:8000`.

The sets `Add.magicLinkAuth` and `Add.magicLinkAuthWiring` are designed to work on Lamdera apps.  
The `Add.pages` rule set works on any suitable Elm app.  See the section "Assumptions" below for more information.

# Assumptions


## Adding pages

By inspecting the code for the rule set, one can infer the assumptions that the
underlying app must satisfy.  

```elm
addPage : ( String, String ) -> List Rule
addPage ( pageTitle, routeName ) =
    [ TypeVariant.makeRule "Route" "Route" [ pageTitle ++ "Route" ]
    , ClauseInCase.config "View.Main" "loadedView" (pageTitle ++ "Route") ("pageHandler model Pages." ++ pageTitle ++ ".view") |> ClauseInCase.makeRule
    , Import.qualified "View.Main" [ "Pages." ++ pageTitle ] |> Import.makeRule
    , ElementToList.makeRule "Route" "routesAndNames" [ "(" ++ pageTitle ++ "Route, \"" ++ routeName ++ "\")" ]
    ]
```

Thus the `Add.pages` rule set assumes that

- The app has a `Route` module that exports a `Route` type and a value `routesAndNames : List (String, String)` 
- The `routesAndNames` value is a list of pairs of strings, the first of which is the name of a route, 
  the second of which is the name of the route as it appears in the URL.  This structure is used 
  to implement the tabs in the mnenu bar.
- The app has a `View.Main` module that exports a `loadedView` function that maps routes to page handlers.
- The app has access to modules that define the pages.  These modules are names`Pages.pageTitle`; they export a `view` function.

Note the app built in the `demo` directory has access to modules `Pages.Quotes` and `Pages.Jokes`
which (for the moment) reside in `vendor/magic-link`.

## Adding magic link authentication

(( Under Construction ))

# Roadmap

This is project is a work in progress, with the roadmap emerging as we work on it. Some of the considerations:

- Make clear the assumptions on the base app.  Can these be made configurable (to some reasonable extent)?

- What other installers might be useful beyond adding pages and magic link authentication?

  - How can we make the installers easier to use, e.g., how do we handle what are now the vendored files.

- How can we make the installers more robust?

- Etc.

# Team

Contributors are Jim Carlson and Mateus Leite.  We welcome feeback and pull requests,
both for this package and the one that underlies it,
[jxxcarlson/elm-review-codeinstaller](https://package.elm-lang.org/packages/jxxcarlson/elm-review-codeinstaller/latest/).