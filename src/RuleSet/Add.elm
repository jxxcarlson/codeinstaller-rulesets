module RuleSet.Add exposing (pages, magicLinkAuth)

{-| Rules for adding pages and for adding magic-link authentication to a Lamdera app.

@docs pages, magicLinkAuth

-}

import Install.ClauseInCase as ClauseInCase
import Install.ElementToList as ElementToList
import Install.FieldInTypeAlias as FieldInTypeAlias
import Install.Function.ReplaceFunction as ReplaceFunction
import Install.Import as Import exposing (module_, qualified, withAlias, withExposedValues)
import Install.Initializer as Initializer
import Install.InitializerCmd as InitializerCmd
import Install.Subscription as Subscription
import Install.Type
import Install.TypeVariant as TypeVariant
import Regex
import Review.Rule exposing (Rule)
import String.Extra


{-| Add magic-link authentication to a Lamdera app:

    configMagicLinkAuth "JC Maxwell" "maxwell" "maxwell@gmail.com"

This configures the base app with magic-link authentication, where
user `maxwell` is the administrator.

-}
magicLinkAuth : String -> String -> String -> List Rule
magicLinkAuth fullname username email =
    configAll { fullname = fullname, username = username, email = email }


stringifyAdminConfig : { fullname : String, username : String, email : String } -> String
stringifyAdminConfig { fullname, username, email } =
    "{ fullname = " ++ String.Extra.quote fullname ++ ", username = " ++ String.Extra.quote username ++ ", email = " ++ String.Extra.quote email ++ "}"


configAll : { fullname : String, username : String, email : String } -> List Rule
configAll adminConfig =
    List.concat
        [ configAtmospheric
        , configUsers
        , configAuthTypes
        , configAuthFrontend
        , configAuthBackend adminConfig
        , configRoute
        , newPages
        , configView
        ]


configAtmospheric : List Rule
configAtmospheric =
    [ -- Add fields randomAtmosphericNumbers and time to BackendModel
      Import.qualified "Types" [ "Http" ] |> Import.makeRule
    , Import.qualified "Backend" [ "Atmospheric", "Dict", "Time", "Task", "MagicLink.Helper", "MagicLink.Backend", "MagicLink.Auth" ] |> Import.makeRule
    , FieldInTypeAlias.makeRule "Types"
        "BackendModel"
        [ "randomAtmosphericNumbers : Maybe (List Int)"
        , "time : Time.Posix"
        ]
    , TypeVariant.makeRule "Types"
        "BackendMsg"
        [ "GotAtmosphericRandomNumbers (Result Http.Error String)"
        , "SetLocalUuidStuff (List Int)"
        , "GotFastTick Time.Posix"
        ]
    , InitializerCmd.makeRule "Backend" "init" [ "Time.now |> Task.perform GotFastTick", "MagicLink.Helper.getAtmosphericRandomNumbers" ]
    , ClauseInCase.config "Backend" "update" "GotAtmosphericRandomNumbers randomNumberString" "Atmospheric.setAtmosphericRandomNumbers model randomNumberString" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "update" "SetLocalUuidStuff randomInts" "(model, Cmd.none)" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "update" "GotFastTick time" "( { model | time = time } , Cmd.none )" |> ClauseInCase.makeRule
    ]


configUsers : List Rule
configUsers =
    [ Import.qualified "Types" [ "User" ] |> Import.makeRule
    , Import.config "Types" [ module_ "Dict" |> withExposedValues [ "Dict" ] ] |> Import.makeRule
    , FieldInTypeAlias.makeRule "Types"
        "BackendModel"
        [ "users: Dict.Dict User.EmailString User.User"
        , "userNameToEmailString : Dict.Dict User.Username User.EmailString"
        ]
    , FieldInTypeAlias.makeRule "Types" "LoadedModel" [ "users : Dict.Dict User.EmailString User.User" ]
    , Import.qualified "Backend" [ "Time", "Task", "LocalUUID" ] |> Import.makeRule
    , Import.config "Backend"
        [ module_ "MagicLink.Helper" |> withAlias "Helper"
        , module_ "Dict" |> withExposedValues [ "Dict" ]
        ]
        |> Import.makeRule
    , Import.qualified "Frontend" [ "Dict" ] |> Import.makeRule
    , Initializer.makeRule "Frontend" "initLoaded" [ { field = "users", value = "Dict.empty" } ]
    ]


configMagicLinkMinimal : List Rule
configMagicLinkMinimal =
    [ Import.qualified "Types" [ "Auth.Common", "MagicLink.Types" ] |> Import.makeRule
    , TypeVariant.makeRule "Types" "FrontendMsg" [ "AuthFrontendMsg MagicLink.Types.Msg" ]
    , TypeVariant.makeRule "Types" "BackendMsg" [ "AuthBackendMsg Auth.Common.BackendMsg" ]
    , TypeVariant.makeRule "Types" "ToBackend" [ "AuthToBackend Auth.Common.ToBackend" ]
    , FieldInTypeAlias.makeRule "Types" "LoadedModel" [ "magicLinkModel : MagicLink.Types.Model" ]
    , Import.qualified "Frontend" [ "MagicLink.Types", "Auth.Common", "MagicLink.Frontend", "MagicLink.Auth", "Pages.SignIn", "Pages.Home", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes" ] |> Import.makeRule
    , Import.qualified "Backend" [ "Auth.Flow" ] |> Import.makeRule
    , Initializer.makeRule "Frontend" "initLoaded" [ { field = "magicLinkModel", value = "Pages.SignIn.init loadingModel.initUrl" } ]
    , TypeVariant.makeRule "Types"
        "ToFrontend"
        [ "AuthToFrontend Auth.Common.ToFrontend"
        , "AuthSuccess Auth.Common.UserInfo"
        , "UserInfoMsg (Maybe Auth.Common.UserInfo)"
        , "GetLoginTokenRateLimited"
        , "RegistrationError String"
        , "SignInError String"
        ]
    , ClauseInCase.config "Backend" "updateFromFrontend" "AuthToBackend authMsg" "Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model" |> ClauseInCase.makeRule
    ]


configAuthTypes : List Rule
configAuthTypes =
    [ Import.qualified "Types" [ "AssocList", "Auth.Common", "LocalUUID", "MagicLink.Types", "Session" ] |> Import.makeRule
    , TypeVariant.makeRule "Types"
        "FrontendMsg"
        [ "SignInUser User.SignInData"
        , "AuthFrontendMsg MagicLink.Types.Msg"
        , "SetRoute_ Route"
        , "LiftMsg MagicLink.Types.Msg"
        ]
    , TypeVariant.makeRule "Types"
        "BackendMsg"
        [ "AuthBackendMsg Auth.Common.BackendMsg"
        , "AutoLogin SessionId User.SignInData"
        , "OnConnected SessionId ClientId"
        ]
    , FieldInTypeAlias.makeRule "Types"
        "BackendModel"
        [ "localUuidData : Maybe LocalUUID.Data"
        , "pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth"
        , "pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth"
        , "sessions : Dict SessionId Auth.Common.UserInfo"
        , "secretCounter : Int"
        , "sessionDict : AssocList.Dict SessionId String"
        , "pendingLogins : MagicLink.Types.PendingLogins"
        , "log : MagicLink.Types.Log"
        , "sessionInfo : Session.SessionInfo"
        ]
    , TypeVariant.makeRule "Types"
        "ToBackend"
        [ "AuthToBackend Auth.Common.ToBackend"
        , "AddUser String String String"
        , "RequestSignUp String String String"
        , "GetUserDictionary"
        ]
    , FieldInTypeAlias.makeRule "Types" "LoadedModel" [ "magicLinkModel : MagicLink.Types.Model" ]
    ]


configAuthFrontend : List Rule
configAuthFrontend =
    [ Import.qualified "Frontend" [ "MagicLink.Types", "Auth.Common", "MagicLink.Frontend", "MagicLink.Auth", "Pages.SignIn", "Pages.Home", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes" ] |> Import.makeRule
    , Initializer.makeRule "Frontend" "initLoaded" [ { field = "magicLinkModel", value = "Pages.SignIn.init loadingModel.initUrl" } ]
    , ClauseInCase.config "Frontend" "updateFromBackendLoaded" "AuthToFrontend authToFrontendMsg" "MagicLink.Auth.updateFromBackend authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })"
        |> ClauseInCase.withInsertAtBeginning
        |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateFromBackendLoaded" "GotUserDictionary users" "( { model | users = users }, Cmd.none )"
        |> ClauseInCase.withInsertAtBeginning
        |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateFromBackendLoaded" "UserRegistered user" "MagicLink.Frontend.userRegistered model.magicLinkModel user |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })"
        |> ClauseInCase.withInsertAtBeginning
        |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateFromBackendLoaded" "GotMessage message" "({model | message = message}, Cmd.none)"
        |> ClauseInCase.withInsertAtBeginning
        |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateLoaded" "SetRoute_ route" "( { model | route = route }, Cmd.none )" |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateLoaded" "AuthFrontendMsg authToFrontendMsg" "MagicLink.Auth.update authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })" |> ClauseInCase.makeRule
    , ClauseInCase.config "Frontend" "updateLoaded" "SignInUser userData" "MagicLink.Frontend.signIn model userData" |> ClauseInCase.makeRule
    , TypeVariant.makeRule "Types"
        "ToFrontend"
        [ "AuthToFrontend Auth.Common.ToFrontend"
        , "AuthSuccess Auth.Common.UserInfo"
        , "UserInfoMsg (Maybe Auth.Common.UserInfo)"
        , "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
        , "GetLoginTokenRateLimited"
        , "RegistrationError String"
        , "SignInError String"
        , "UserSignedIn (Maybe User.User)"
        , "UserRegistered User.User"
        , "GotUserDictionary (Dict.Dict User.EmailString User.User)"
        , "GotMessage String"
        ]
    , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int" ]
    , ClauseInCase.config "Frontend" "updateLoaded" "LiftMsg _" "( model, Cmd.none )" |> ClauseInCase.makeRule
    , ReplaceFunction.config "Frontend" "tryLoading" tryLoading2
        |> ReplaceFunction.makeRule
    ]


configAuthBackend : { fullname : String, username : String, email : String } -> List Rule
configAuthBackend adminConfig =
    [ ClauseInCase.config "Backend" "update" "AuthBackendMsg authMsg" "Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "update" "AutoLogin sessionId loginData" "( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "update" "OnConnected sessionId clientId" "( model, Reconnect.connect model sessionId clientId )" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "update" "ClientConnected sessionId clientId" "( model, Reconnect.connect model sessionId clientId )" |> ClauseInCase.makeRule
    , Import.qualified "Backend"
        [ "AssocList"
        , "Auth.Common"
        , "Auth.Flow"
        , "MagicLink.Auth"
        , "MagicLink.Backend"
        , "Reconnect"
        , "User"
        ]
        |> Import.makeRule
    , Initializer.makeRule "Backend"
        "init"
        [ { field = "randomAtmosphericNumbers", value = "Just [ 235880, 700828, 253400, 602641 ]" }
        , { field = "time", value = "Time.millisToPosix 0" }
        , { field = "sessions", value = "Dict.empty" }
        , { field = "userNameToEmailString", value = "Dict.fromList [ (\"jxxcarlson\", \"jxxcarlson@gmail.com\") ]" }
        , { field = "users", value = "MagicLink.Helper.initialUserDictionary " ++ stringifyAdminConfig adminConfig }
        , { field = "sessionInfo", value = "Dict.empty" }
        , { field = "pendingAuths", value = "Dict.empty" }
        , { field = "localUuidData", value = "LocalUUID.initFrom4List [ 235880, 700828, 253400, 602641 ]" }
        , { field = "pendingEmailAuths", value = "Dict.empty" }
        , { field = "secretCounter", value = "0" }
        , { field = "sessionDict", value = "AssocList.empty" }
        , { field = "pendingLogins", value = "AssocList.empty" }
        , { field = "log", value = "[]" }
        ]
    , ClauseInCase.config "Backend" "updateFromFrontend" "AuthToBackend authMsg" "Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "updateFromFrontend" "AddUser realname username email" "MagicLink.Backend.addUser model clientId email realname username" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "updateFromFrontend" "RequestSignUp realname username email" "MagicLink.Backend.requestSignUp model clientId realname username email" |> ClauseInCase.makeRule
    , ClauseInCase.config "Backend" "updateFromFrontend" "GetUserDictionary" "( model, Lamdera.sendToFrontend clientId (GotUserDictionary model.users) )" |> ClauseInCase.makeRule
    , Subscription.makeRule "Backend" [ "Lamdera.onConnect OnConnected" ]
    ]


configRoute : List Rule
configRoute =
    [ -- ROUTE
      TypeVariant.makeRule "Route" "Route" [ "NotesRoute", "SignInRoute", "AdminRoute" ]
    , ElementToList.makeRule "Route" "routesAndNames" [ "(NotesRoute, \"notes\")", "(SignInRoute, \"signin\")", "(AdminRoute, \"admin\")" ]
    ]


newPages =
    pages [ ( "TermsOfService", "terms" ) ]


{-| Add pages to a Lamdera app:

    RuleSet.Add.pages [ ( "QuotesRoute", "quotes" ), ( "QuotesRoute", "jokes" ) ]

adds pages for quotes and jokes to the app. The routes are `QuotesRoute` and `QuotesRoute`
and the paths for the routes are `quotes` and `jokes`, respectively.

-}
pages : List ( String, String ) -> List Rule
pages pageData =
    List.concatMap addPage pageData


addPage : ( String, String ) -> List Rule
addPage ( pageTitle, routeName ) =
    [ TypeVariant.makeRule "Route" "Route" [ pageTitle ++ "Route" ]
    , ClauseInCase.config "View.Main" "loadedView" (pageTitle ++ "Route") ("pageHandler model Pages." ++ pageTitle ++ ".view") |> ClauseInCase.makeRule
    , Import.qualified "View.Main" [ "Pages." ++ pageTitle ] |> Import.makeRule
    , ElementToList.makeRule "Route" "routesAndNames" [ "(" ++ pageTitle ++ "Route, \"" ++ routeName ++ "\")" ]
    ]


configView : List Rule
configView =
    [ ClauseInCase.config "View.Main" "loadedView" "AdminRoute" adminRoute |> ClauseInCase.makeRule
    , ClauseInCase.config "View.Main" "loadedView" "NotesRoute" "pageHandler model Pages.Notes.view" |> ClauseInCase.makeRule
    , ClauseInCase.config "View.Main" "loadedView" "SignInRoute" "pageHandler model (\\model_ -> Pages.SignIn.view Types.LiftMsg model_.magicLinkModel |> Element.map Types.AuthFrontendMsg)" |> ClauseInCase.makeRule
    , ClauseInCase.config "View.Main" "loadedView" "CounterPageRoute" "pageHandler model Pages.Counter.view" |> ClauseInCase.makeRule
    , Import.qualified "View.Main" [ "MagicLink.Helper", "Pages.Counter", "Pages.SignIn", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes", "User" ] |> Import.makeRule
    , ReplaceFunction.config "View.Main" "headerRow" headerRow |> ReplaceFunction.makeRule
    , ReplaceFunction.config "View.Main" "makeLinks" makeLinks |> ReplaceFunction.makeRule
    ]


makeLinks =
    """makeLinks model route =
    case model.magicLinkModel.currentUserData of
        Just user ->
            homePageLink route
                :: List.map (makeLink route) (Route.routesAndNames |> List.filter (\\(r, n) -> n /= "signin") |> MagicLink.Helper.adminFilter user)


        Nothing ->
            homePageLink route
                :: List.map (makeLink route) (Route.routesAndNames |> List.filter (\\( r, n ) -> n /= "admin"))
 """


headerRow =
    """headerRow model = [ headerView model model.route { window = model.window, isCompact = True }, Pages.SignIn.showCurrentUser model |> Element.map Types.AuthFrontendMsg]"""



-- VALUES USED IN THE RULES:


adminRoute =
    "if User.isAdmin model.magicLinkModel.currentUserData then pageHandler model Pages.Admin.view else pageHandler model Pages.Home.view"


tryLoading2 =
    """tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\\window ->
            case loadingModel.route of
                _ ->
                    let
                        authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                    in
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , counter = 0
                        , window = window
                        , showTooltip = False
                        , magicLinkModel = Pages.SignIn.init authRedirectBaseUrl
                        , route = loadingModel.route
                        , message = "Starting up ..."
                        , users = Dict.empty
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )"""



-- Function to compress runs of spaces to a single space


asOneLine : String -> String
asOneLine str =
    str
        |> String.trim
        |> compressSpaces
        |> String.split "\n"
        |> String.join " "


compressSpaces : String -> String
compressSpaces string =
    userReplace " +" (\_ -> " ") string


userReplace : String -> (Regex.Match -> String) -> String -> String
userReplace userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string
