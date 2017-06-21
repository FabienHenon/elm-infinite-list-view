module CustomContainer exposing (main)

import InfiniteList as IL
import Html exposing (Html, div, text, ul, li)
import Html.Attributes exposing (style)


type Msg
    = InfListMsg IL.Model


type alias Model =
    { infList : IL.Model
    , content : List String
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initModel : Model
initModel =
    { infList = IL.init
    , content = List.range 0 1000 |> List.map toString
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            initModel
    in
        ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InfListMsg infList ->
            ( { model | infList = infList }, Cmd.none )


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
        , itemHeight = itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300
        |> IL.withCustomContainer customContainer


customContainer : List ( String, String ) -> List (Html msg) -> Html msg
customContainer styles children =
    ul [ style (styles ++ [ ( "padding-left", "40px" ) ]) ] children


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    li
        [ style
            [ ( "height", (toString itemHeight) ++ "px" ) ]
        ]
        [ text item ]


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "height", (toString containerHeight) ++ "px" )
            , ( "width", "500px" )
            , ( "overflow", "auto" )
            , ( "border", "1px solid #000" )
            , ( "margin", "auto" )
            ]
        , IL.onScroll InfListMsg
        ]
        [ IL.view config model.infList model.content ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
