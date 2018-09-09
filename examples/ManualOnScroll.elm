module ManualOnScroll exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (on)
import InfiniteList as IL
import Json.Decode as JD


type Msg
    = OnScroll JD.Value


type alias Model =
    { infList : IL.Model
    , content : List String
    }


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


init : Model
init =
    { infList = IL.init
    , content = List.range 0 1000 |> List.map String.fromInt
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        OnScroll value ->
            let
                infList =
                    IL.updateScroll value model.infList
            in
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
        , itemHeight = IL.constantHeight itemHeight
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
        , on "scroll" (JD.map OnScroll JD.value)
        ]
        [ IL.view config model.infList model.content ]
