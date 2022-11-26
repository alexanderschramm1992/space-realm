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
import Html.Events exposing (onClick, onInput)
import Json.Decode exposing (Decoder)
import List exposing (map)
import Html.Attributes exposing (style)
import Html exposing (img)
import Html.Attributes exposing (src)

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
    { player: Player
    , solarSystem: Maybe SolarSystem
    , error: Maybe String }

type alias Credentials =
  { username: Maybe String
  , password: Maybe String }

type alias Id = String

type alias Name = String

type alias Image = String

type alias Coordinates = 
  { top: Int
  , left: Int }

type alias Player =
  { id: Id
  , name: Name
  , solarSystem: Id
  , currency: Int }

type alias SolarSystem =
  { id: Id
  , name: Name
  , planets: List Planet }

type alias Planet =
  { id: Id
  , name: Name
  , image: Image
  , position: Coordinates}

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
  | SolarSystemResponded Json.Decode.Value

-- PORTS

port sendLoginRequest: Credentials -> Cmd msg
port receiveLoginResponse: (Json.Decode.Value -> msg) -> Sub msg
port sendErrorMessage: String -> Cmd msg
port sendSolarSystemRequest: Id -> Cmd msg
port receiveSolarSystemResponse: (Json.Decode.Value -> msg) -> Sub msg

-- SUBSCRIPTIONS

subscriptions: Model -> Sub Msg
subscriptions _ = Sub.batch 
  [ receiveLoginResponse (LandingPageMsg << LoginResponded)
  , receiveSolarSystemResponse (SolarSystemMsg << SolarSystemResponded) ]

-- DECODERS

coordinatesDecoder: Decoder Coordinates
coordinatesDecoder = Json.Decode.map2 Coordinates
  (Json.Decode.field "top" Json.Decode.int)
  (Json.Decode.field "left" Json.Decode.int)

planetDecoder: Decoder Planet
planetDecoder = Json.Decode.map4 Planet
  (Json.Decode.field "id" Json.Decode.string)
  (Json.Decode.field "name" Json.Decode.string)
  (Json.Decode.field "image" Json.Decode.string)
  (Json.Decode.field "position" coordinatesDecoder)

playerDecoder: Decoder Player
playerDecoder = Json.Decode.map4 Player 
  (Json.Decode.field "id" Json.Decode.string)
  (Json.Decode.field "name" Json.Decode.string)
  (Json.Decode.field "id" Json.Decode.string)
  (Json.Decode.field "currency" Json.Decode.int)

solarSystemDecoder: Decoder SolarSystem
solarSystemDecoder = Json.Decode.map3 SolarSystem
  (Json.Decode.field "id" Json.Decode.string)
  (Json.Decode.field "name" Json.Decode.string)
  (Json.Decode.field "planets" (Json.Decode.list planetDecoder))

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

updateMapPage: SolarSystemMsg -> Model -> (Model, Cmd Msg)
updateMapPage msg model =
  case model of
      SolarSystemModel _ -> case msg of
          LogoutClicked ->
            ( LandingPageModel 
              { username = Nothing
              , password = Nothing
              , error = Nothing }
            , Cmd.none )
          SolarSystemResponded response -> processSolarSystemResponse response model
      _ -> (model, Cmd.none)

processLoginResponse: Json.Decode.Value -> Model -> (Model, Cmd Msg)
processLoginResponse response model = case model of
  LandingPageModel content -> case Json.Decode.decodeValue playerDecoder response of
    Err error -> 
      ( LandingPageModel { content | error = Just (Json.Decode.errorToString error) }
      , sendErrorMessage (Json.Decode.errorToString error) )
    Ok player -> 
      ( SolarSystemModel 
        { player = player 
        , solarSystem = Nothing
        , error = Nothing }
      , sendSolarSystemRequest player.solarSystem )
  _ -> (model, Cmd.none)

processSolarSystemResponse: Json.Decode.Value -> Model -> (Model, Cmd Msg)
processSolarSystemResponse response model = case model of
    SolarSystemModel content -> case Json.Decode.decodeValue solarSystemDecoder response of
        Err error -> 
          ( SolarSystemModel { content | error = Just (Json.Decode.errorToString error) }
          , sendErrorMessage (Json.Decode.errorToString error) )
        Ok solarSystem ->
          ( SolarSystemModel { content | solarSystem = Just solarSystem }
          , Cmd.none)
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
landingPageView model = div
  [ class "flex-box" ]
  [ div 
    [ class "panel glow vertical-center" ] 
    [ div
      [ class "center" ]
      [ text "Space Realm" ]
    , loginPanel model ] ]

loginPanel: Model -> Html Msg
loginPanel model = div
  [ class "panel" ]
  [ input
    [ type_ "text"
    , placeholder "Benutzername"
    , onInput (LandingPageMsg << UsernameSet) ]
    []
  , br [] []
  , input
    [ type_ "password" 
    , placeholder "Passwort"
    , onInput (LandingPageMsg << PasswordSet) ]
    []
  , br [] []
  , input
    [ type_ "button"
    , value "Login"
    , onClick (LandingPageMsg LoginRequested) ]
    [] ]

solarSystemView: Model -> Html Msg
solarSystemView model = case model of
    SolarSystemModel content -> case content.solarSystem of
      Just solarSystem -> div
        [ class "flex-box" ]
        [ div 
          [ class "panel glow full" ] 
          [ text ("Solar System - " ++ solarSystem.name) ]
        , solarSystemMapView solarSystem
        , solarSystemElementView solarSystem ]
      Nothing -> div [] []
    _ -> div [] []

solarSystemMapView: SolarSystem -> Html Msg
solarSystemMapView solarSystem = 
  div 
    [ class "half-square map glow" ] 
    ( map planetView solarSystem.planets )

planetView: Planet -> Html Msg
planetView planet = img 
  [ class "planet"
  , style "top" ((String.fromInt planet.position.top) ++ "vmax")
  , style "left" ((String.fromInt planet.position.left) ++ "vmax") 
  , src planet.image ] 
  []

solarSystemElementView: SolarSystem -> Html Msg
solarSystemElementView model = 
  div 
    [ class "panel glow half" ] 
    [ ]