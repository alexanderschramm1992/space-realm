module Main exposing(..)

import Browser
import Html exposing (Html, text)
import Html exposing (div)
import Html.Attributes exposing (class)
import Html exposing (input)
import Html.Attributes exposing (type_)
import Html.Attributes exposing (placeholder)
import Html exposing (br)
import Html.Attributes exposing (value)
import Html.Attributes exposing (align)

type Model = Model

type Msg = Msg

type alias Document msg =
  { title : String
  , body : List (Html msg) }

main : Program () Model Msg
main = Browser.document
  { init= init
  , view= view
  , update= update
  , subscriptions= subscriptions }

init: () -> (Model, Cmd Msg)
init = \_ -> (Model, Cmd.none)

view: Model -> Document Msg
view model = 
  { title = "Space Realm"
  , body = [
    div 
      [ class "background" ] 
      [ div 
        [ class "panel glow" ] 
        [ div
          [ class "center" ]
          [ text "Space Realm" ]
        , login model ] ] ] }

login: Model -> Html Msg
login model = div
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
    , value "Login" ]
    [ ] ]

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msg -> (Model, Cmd.none)

subscriptions: Model  -> Sub Msg
subscriptions model = Sub.none
