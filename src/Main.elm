port module Main exposing(..)

import Browser
import Html exposing (Html, text)
import Html exposing (div)
import Html.Attributes exposing (class)
import Html exposing (input)
import Html.Attributes exposing (type_)
import Html.Attributes exposing (placeholder)
import Html exposing (br)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder)

-- MAIN

type alias Document msg =
  { title : String
  , body : List (Html msg) }

main : Program () Model Msg
main = Browser.document
  { init= init
  , view= view
  , update= update
  , subscriptions= subscriptions }

-- MODEL

type Model 
  = LandingPageModel 
    { username: Maybe String
    , password: Maybe String
    , error: Maybe String }
  | SolarSystemModel
    { player: Player }

type alias Credentials =
  { username: Maybe String
  , password: Maybe String }

type alias Player =
  { id: String
  , name: String
  , currency: Int }

-- MSG

type Msg 
  = LandingPageMsg LandingPageMsg
  | SolarSystemMsg SolarSystemMsg

type LandingPageMsg
  = UsernameSet String
  | PasswordSet String
  | LoginRequested
  | LoginResponded Json.Decode.Value

type SolarSystemMsg
  = LogoutClicked

-- PORTS

port sendLoginRequest: Credentials -> Cmd msg
port receiveLoginResponse: (Json.Decode.Value -> msg) -> Sub msg
port sendErrorMessage: String -> Cmd msg

-- SUBSCRIPTIONS

subscriptions: Model -> Sub Msg
subscriptions model = receiveLoginResponse (\value -> LandingPageMsg (LoginResponded value))

-- INIT

init: () -> (Model, Cmd Msg)
init = \_ -> (
  LandingPageModel 
    { username = Nothing
    , password = Nothing
    , error = Nothing }
  , Cmd.none)

-- UDPATE

update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
      LandingPageMsg landingPageMsg -> updateLandingPage landingPageMsg model
      SolarSystemMsg mapPageMsg -> updateMapPage mapPageMsg model
            
updateLandingPage: LandingPageMsg -> Model -> (Model, Cmd Msg)
updateLandingPage msg model =
  case model of
    LandingPageModel content -> case msg of
      UsernameSet username ->
        ( LandingPageModel { content | username = Just username }
        , Cmd.none)
      PasswordSet password -> 
        ( LandingPageModel { content | password = Just password} 
        , Cmd.none)
      LoginRequested -> (model, sendLoginRequest 
        { username = content.username
        , password = content.password })
      LoginResponded response -> processLoginResponse response model
    _ -> (model, Cmd.none)

processLoginResponse: Json.Decode.Value -> Model -> (Model, Cmd Msg)
processLoginResponse response model = case model of
  LandingPageModel content -> case decodePlayer response of
    Err error -> (
      LandingPageModel { content | error = Just (Json.Decode.errorToString error) }
      , sendErrorMessage (Json.Decode.errorToString error))
    Ok player -> (
      SolarSystemModel { player = player }, 
      Cmd.none)
  _ -> (model, Cmd.none)

playerDecoder: Decoder Player
playerDecoder = Json.Decode.map3 Player 
  (Json.Decode.field "id" Json.Decode.string)
  (Json.Decode.field "name" Json.Decode.string)
  (Json.Decode.field "currency" Json.Decode.int)

decodePlayer: Json.Decode.Value -> Result Json.Decode.Error Player
decodePlayer json = Json.Decode.decodeValue playerDecoder json 

updateMapPage: SolarSystemMsg -> Model -> (Model, Cmd Msg)
updateMapPage msg model =
  case model of
      SolarSystemModel content -> case msg of
          LogoutClicked ->
            ( LandingPageModel 
              { username = Nothing
              , password = Nothing
              , error = Nothing }
            , Cmd.none )
      _ -> (model, Cmd.none)

-- VIEW

view: Model -> Document Msg
view model = 
  { title = case model of
      LandingPageModel _ -> "Space Realm"
      SolarSystemModel _ -> "Solar System"
  , body = [
    div 
      [ class "background" ] 
      [ case model of
        LandingPageModel _ -> landingPageView model
        SolarSystemModel _ -> solarSystemView model ] ] }

landingPageView: Model -> Html Msg
landingPageView model =
  div 
    [ class "panel glow" ] 
    [ div
      [ class "center" ]
      [ text "Space Realm" ]
    , loginPanel model ]

loginPanel: Model -> Html Msg
loginPanel model = div
  [ class "panel" ]
  [ input
    [ type_ "text"
    , placeholder "Benutzername" ]
    []
  , br [] []
  , input
    [ type_ "password" 
    , placeholder "Passwort" ]
    []
  , br [] []
  , input
    [ type_ "button"
    , value "Login"
    , onClick (LandingPageMsg LoginRequested) ]
    [ ] ]

solarSystemView: Model -> Html Msg
solarSystemView model =
  div 
    [ class "panel glow" ] 
    [ text "Solar System - Coming soon" ]
