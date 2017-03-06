module Magicl
  exposing
    ( Magicl
    , compile
    , empty
    , tagName
    , attributes
    , children
    , css
    )

{-| An Elm port of magicl.

# Types
@docs Magicl

# Converters
@docs compile

# Constructors
@docs empty

# Lower level functions
## Lenses
@docs tagName
@docs attributes
@docs children
@docs css
-}

import Css
import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Monocle.Lens as Lens exposing (Lens)


{-| Main type for Magicl.
-}
type Magicl msg
  = Magicl
    { tagName : String
    , attributes : List (Attribute msg)
    , css : List (String -> Css.Mixin)
    , children : List (Magicl msg)
    }


{-| Transpile `Magicl` to [HTML](http://package.elm-lang.org/packages/elm-lang/html/latest) and [elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest).
-}
compile : String -> Magicl msg -> ( Html msg, Css.Stylesheet )
compile namespace magicl =
  let
    ( html, snippet ) =
      compile_ namespace magicl
  in
    ( html, Css.stylesheet [ snippet ] )


compile_ : String -> Magicl msg -> ( Html msg, Css.Snippet )
compile_ id (Magicl { tagName, attributes, css, children }) =
  let
    ( _, htmls_, snippets_ ) =
      List.foldr f ( 0, [], [] ) children

    f : Magicl msg -> ( Int, List (Html msg), List Css.Snippet ) -> ( Int, List (Html msg), List Css.Snippet )
    f magicl ( n, htmls, snippets ) =
      let
        id_ =
          id ++ "-" ++ toString n

        ( html, snippet ) =
          compile_ id_ magicl
      in
        ( n + 1, html :: htmls, snippet :: snippets )
  in
    ( Html.node
      tagName
      (Attributes.class id :: attributes)
      htmls_
    , Css.class id <|
      Css.children snippets_
        :: List.map (\f -> f id) css
    )


{-| An empty value of `Magicl`.
-}
empty : Magicl msg
empty =
  Magicl
    { tagName = "div"
    , attributes = []
    , css = []
    , children = []
    }


setStyle : List Css.Mixin -> Magicl msg -> Magicl msg
setStyle styles =
  Lens.modify css (\ls -> (List.map always styles) ++ ls)


setStyleOn : state -> List Css.Mixin -> Magicl msg -> Magicl msg
setStyleOn state styles =
  let
    css_ : String -> Css.Mixin
    css_ id =
      Css.withClass (id ++ "-" ++ toString state) styles
  in
    Lens.modify css (\ls -> css_ :: ls)



-- Lower level functions


{-| Lens for tag name.
-}
tagName : Lens (Magicl msg) String
tagName =
  let
    get (Magicl magicl) =
      magicl.tagName

    set tag (Magicl magicl) =
      Magicl
        { magicl | tagName = tag }
  in
    Lens get set


{-| Lens for attributes.
-}
attributes : Lens (Magicl msg) (List (Attribute msg))
attributes =
  let
    get (Magicl magicl) =
      magicl.attributes

    set a (Magicl magicl) =
      Magicl
        { magicl | attributes = a }
  in
    Lens get set


{-| Lens for CSS.
-}
css : Lens (Magicl msg) (List (String -> Css.Mixin))
css =
  let
    get (Magicl magicl) =
      magicl.css

    set a (Magicl magicl) =
      Magicl
        { magicl | css = a }
  in
    Lens get set


{-| Lens for children.
-}
children : Lens (Magicl msg) (List (Magicl msg))
children =
  let
    get (Magicl magicl) =
      magicl.children

    set a (Magicl magicl) =
      Magicl
        { magicl | children = a }
  in
    Lens get set
