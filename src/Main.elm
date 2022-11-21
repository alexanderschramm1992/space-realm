module Main exposing(..)

import Browser
import Html exposing (Html, text)
import Html exposing (div)
import Html.Attributes exposing (class)

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
      [class "background"] 
      [div 
        [class "panel"] 
        [ text "Hello Space!"] ] ] }

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msg -> (Model, Cmd.none)

subscriptions: Model  -> Sub Msg
subscriptions model = Sub.none
