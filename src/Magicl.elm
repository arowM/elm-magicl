module Magicl
  exposing
    ( Magicl
    , compile
    , empty
    )

{-| An Elm port of magicl.

# Types
@docs Magicl

# Converters
@docs compile

# Constructors
@docs empty
-}

import Css
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


{-| Main type for Magicl.
-}
type Magicl msg
  = Magicl
    { tagName : String
    , attributes : List (Html.Attribute msg)
    , css : List Css.Mixin
    , children : List (Magicl msg)
    }


{-| Transpile `Magicl` to [HTML](http://package.elm-lang.org/packages/elm-lang/html/latest) and [elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest).
-}
compile : Magicl msg -> (Html msg, Css.Stylesheet)
compile magicl =
  let
    (html, snippet) = compile_ [0] magicl
  in
    (html, Css.stylesheet [ snippet ])

compile_ : List Int -> Magicl msg -> (Html msg, Css.Snippet)
compile_ id (Magicl {tagName, attributes, css, children}) =
  let
    (_, htmls_, snippets_) =
      List.foldr
        (\a (ns, htmls, snippets) ->
          let
            id_ = case ns of
              (n_ :: ns_) ->
                (n_ + 1) :: ns_
              [] ->
                []
            (html, snippet) = compile_ id_ a
          in (id_, html :: htmls, snippet :: snippets)
        )
        (0 :: id, [], []) children
    className = String.join "-" <| List.map toString id
  in
    ( Html.node
      tagName
      (Attributes.class className :: attributes)
      htmls_
    , Css.class className
      <| Css.children snippets_ :: css
    )


{-| An empty value of `Magicl`.
-}
empty : Magicl msg
empty = Magicl
  { tagName = "div"
  , attributes = []
  , css = []
  , children = []
  }
