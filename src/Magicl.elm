module Magicl
  exposing
    ( Magicl
    , compile
    , empty
    , setState
    , setStyle
    , setStyleOn
    , combineRight
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

# Setters
@docs setState
@docs setStyle
@docs setStyleOn

# Combinators
@docs combineRight

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
type Magicl msg state
  = Magicl
    { tagName : String
    , attributes : List (Attribute msg)
    , css : List (String -> Css.Snippet)
    , children : List (Magicl msg ())
    , direction : Direction
    }


type Direction
  = NoDirection
  | ToRight
  | ToBottom


{-| Transpile `Magicl` to [HTML](http://package.elm-lang.org/packages/elm-lang/html/latest) and [elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest).
-}
compile : String -> Magicl msg state -> ( Html msg, Css.Stylesheet )
compile namespace magicl =
  let
    ( html, snippets ) =
      compile_ namespace <| coerce magicl
  in
    ( html, Css.stylesheet snippets )


compile_ : String -> Magicl msg () -> ( Html msg, List Css.Snippet )
compile_ id (Magicl { tagName, attributes, css, children }) =
  let
    ( _, htmls_, snippets_ ) =
      List.foldr f ( 0, [], [] ) children

    f : Magicl msg () -> ( Int, List (Html msg), List Css.Snippet ) -> ( Int, List (Html msg), List Css.Snippet )
    f magicl ( n, htmls, snippets ) =
      let
        id_ =
          id ++ "-" ++ toString n

        ( html, snippet ) =
          compile_ id_ magicl
      in
        ( n + 1, html :: htmls, snippet ++ snippets )
  in
    ( Html.node
      tagName
      (Attributes.class id :: attributes)
      htmls_
    , snippets_
    )


{-| An empty value of `Magicl`.
-}
empty : Magicl msg state
empty =
  Magicl
    { tagName = "div"
    , attributes = []
    , css = []
    , children = []
    , direction = NoDirection
    }


{-| Set state of `Magicl msg state` value.
-}
setState : state -> Magicl msg state -> Magicl msg state
setState state =
  Lens.modify attributes <|
    \attr -> Attributes.attribute "data-magicl-state" (toString state) :: attr


{-| Set style for anytime.
-}
setStyle : List Css.Mixin -> Magicl msg state -> Magicl msg state
setStyle styles =
  Lens.modify css (\ls -> (\id -> Css.class id styles) :: ls)


{-| Set style for specific state.
-}
setStyleOn : state -> List Css.Mixin -> Magicl msg state -> Magicl msg state
setStyleOn state styles =
  let
    css_ : String -> Css.Snippet
    css_ id =
      Css.selector ("." ++ id ++ "[data-magicl-state=\"" ++ toString state ++ "\"]") styles
  in
    Lens.modify css (\ls -> css_ :: ls)


coerce : Magicl msg a -> Magicl msg b
coerce (Magicl o) =
  Magicl o



-- Combinators


{-| Combine second block to the right side of first block.
-}
combineRight : Magicl msg s0 -> Magicl msg s1 -> Magicl msg ()
combineRight m1 m2 =
  case direction.get m1 of
    ToRight ->
      coerce m1
        |> Lens.modify children (\cs ->
          cs ++
            [ coerce m2
            ]
        )

    _ ->
      empty
        |> tagName.set "div"
        |> direction.set ToRight
        |> Lens.modify css (\ls ->
          (\id ->
            Css.class id
              [ Css.displayFlex
              , Css.flexDirection Css.row
              ]
          ) :: ls
        )
        |> children.set
          [ coerce m1
          , coerce m2
          ]



-- Lower level functions


{-| Lens for tag name.
-}
tagName : Lens (Magicl msg state) String
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
attributes : Lens (Magicl msg state) (List (Attribute msg))
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
css : Lens (Magicl msg state) (List (String -> Css.Snippet))
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
children : Lens (Magicl msg state) (List (Magicl msg ()))
children =
  let
    get (Magicl magicl) =
      magicl.children

    set a (Magicl magicl) =
      Magicl
        { magicl | children = a }
  in
    Lens get set


{-| Lens for direction.
-}
direction : Lens (Magicl msg state) Direction
direction =
  let
    get (Magicl magicl) =
      magicl.direction

    set a (Magicl magicl) =
      Magicl
        { magicl | direction = a }
  in
    Lens get set
