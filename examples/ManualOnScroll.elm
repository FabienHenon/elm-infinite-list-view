module ManualOnScroll exposing (main)

import InfiniteList as IL
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (on)
import Json.Decode as JD


type Msg
    = OnScroll JD.Value


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
        OnScroll value ->
            let
                infList =
                    IL.updateScroll value model.infList
            in
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
        , itemHeight = IL.constantHeight itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    div
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
        , on "scroll" (JD.map OnScroll JD.value)
        ]
        [ IL.view config model.infList model.content ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
