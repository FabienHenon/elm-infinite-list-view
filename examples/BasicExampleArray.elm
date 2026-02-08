module BasicExampleArray exposing (main)

import Array exposing (..)
import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import InfiniteList as IL


type Msg
    = InfListMsg IL.Model


type alias Model =
    { infList : IL.Model
    , content : Array String
    }


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initModel
        , view = view
        , update = update
        }


initModel : Model
initModel =
    { infList = IL.init
    , content = Array.initialize 1000 String.fromInt
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        InfListMsg infList ->
            { model | infList = infList }


itemHeight : Int
itemHeight =
    20


containerHeight : Int
containerHeight =
    500


config : IL.Config String Msg
config =
    IL.config
        { itemView = itemView
        , itemHeight = IL.withConstantHeight itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    div
        [ style "height" (String.fromInt itemHeight ++ "px")
        ]
        [ text item ]


view : Model -> Html Msg
view model =
    div
        [ style "height" (String.fromInt containerHeight ++ "px")
        , style "width" "500px"
        , style "overflow" "auto"
        , style "border" "1px solid #000"
        , style "margin" "auto"
        , IL.onScroll InfListMsg
        ]
        [ IL.viewArray config model.infList model.content ]
