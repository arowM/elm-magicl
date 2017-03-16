module Main exposing (..)

import Css
import Html exposing (..)
import Magicl exposing (..)



-- APP


main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model = ()


init : (Model, Cmd Msg)
init =
  ( ()
  , Cmd.none
  )



-- UPDATE


type Msg
  = Msg


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    Msg ->
      ( model
      , Cmd.none
      )



-- VIEW


view : Model -> Html Msg
view model =
  let
    ( html, _ ) = magicl
  in
    html


magicl : ( Html Msg, Css.Stylesheet )
magicl = compile "foo" <|
  combineRight
    (Magicl.text "baz") <|
    Magicl.text "bar"


css : Css.Stylesheet
css =
  let
    ( _, x ) = magicl
  in
    x



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
