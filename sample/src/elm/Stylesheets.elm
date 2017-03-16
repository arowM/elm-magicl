port module Stylesheets exposing (..)

import Css exposing (..)
import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Css.Namespace exposing (namespace)
import Main exposing (css)


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
  Css.File.toFileStructure
    [ ( "index.css"
      , Css.File.compile
        [ css
        ]
      )
    ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
