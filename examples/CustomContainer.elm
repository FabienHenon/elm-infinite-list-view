module CustomContainer exposing (main)

import Browser
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (style)
import InfiniteList as IL


type Msg
    = InfListMsg IL.Model


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
        , itemHeight = IL.constantHeight itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300
        |> IL.withCustomContainer customContainer


customContainer : List ( String, String ) -> List (Html msg) -> Html msg
customContainer styles children =
    ul ((styles ++ [ ( "padding-left", "40px" ) ]) |> List.map (\( attr, value ) -> style attr value)) children


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    li
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
        [ IL.view config model.infList model.content ]
