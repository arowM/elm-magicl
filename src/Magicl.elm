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
    , css : List Css.Mixin
    , children : List (Magicl msg)
    }


{-| Transpile `Magicl` to [HTML](http://package.elm-lang.org/packages/elm-lang/html/latest) and [elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest).
-}
compile : Magicl msg -> ( Html msg, Css.Stylesheet )
compile magicl =
  let
    ( html, snippet ) =
      compile_ [ 0 ] magicl
  in
    ( html, Css.stylesheet [ snippet ] )


compile_ : List Int -> Magicl msg -> ( Html msg, Css.Snippet )
compile_ id (Magicl { tagName, attributes, css, children }) =
  let
    ( _, htmls_, snippets_ ) =
      List.foldr
        (\a ( ns, htmls, snippets ) ->
          let
            id_ =
              case ns of
                n_ :: ns_ ->
                  (n_ + 1) :: ns_

                [] ->
                  []

            ( html, snippet ) =
              compile_ id_ a
          in
            ( id_, html :: htmls, snippet :: snippets )
        )
        ( 0 :: id, [], [] )
        children

    className =
      String.join "-" <| List.map toString id
  in
    ( Html.node
      tagName
      (Attributes.class className :: attributes)
      htmls_
    , Css.class className <|
      Css.children snippets_
        :: css
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
css : Lens (Magicl msg) (List Css.Mixin)
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
