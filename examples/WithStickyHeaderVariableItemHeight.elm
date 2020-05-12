module WithStickyHeaderVariableItemHeight exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import InfiniteList as IL


type Msg
    = InfListMsg IL.Model


type alias Model =
    { infList : IL.Model
    , content : List ListItem
    }


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initModel
        , view = view
        , update = update
        }


type ListItem
    = Header
    | Row String


initModel : Model
initModel =
    { infList = IL.init
    , content = List.range 0 1000 |> List.map String.fromInt |> List.map Row
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        InfListMsg infList ->
            { model | infList = infList }



itemHeight : Int -> ListItem -> Int
itemHeight _ item =
    case item of
        Header -> 30
        Row _ -> 20


containerHeight : Int
containerHeight =
    500


config : IL.Config ListItem Msg
config =
    IL.config
        { itemView = itemView
        , itemHeight = IL.withVariableHeight itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300
        |> IL.withKeepFirst 1


itemView : Int -> Int -> ListItem -> Html Msg
itemView idx listIdx item =
    case item of
        Header ->
            div
                [ style "height" (String.fromInt (itemHeight idx item) ++ "px")
                , style "position" "sticky"
                , style "top" "0px"
                , style "background" "white"
                ]
                [ text "Number" ]

        Row val ->
            div
                [ style "height" (String.fromInt (itemHeight idx item) ++ "px")
                ]
                [ text val ]


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
        [ IL.view config model.infList (Header :: model.content) ]
