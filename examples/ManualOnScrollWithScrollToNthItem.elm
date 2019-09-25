module ManualOnScrollWithScrollToNthItem exposing (main)

import Browser exposing (Document)
import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (on, onInput)
import InfiniteList as IL
import Json.Decode as JD


type Msg
    = OnScroll JD.Value
    | UserChangedScrollIndex String
    | NoOp


type alias Model =
    { infList : IL.Model
    , content : List String
    }


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { infList = IL.init
      , content = List.range 0 1000 |> List.map String.fromInt
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnScroll value ->
            let
                infList =
                    IL.updateScroll value model.infList
            in
            ( { model | infList = infList }, Cmd.none )

        UserChangedScrollIndex string ->
            case String.toInt string of
                Just idx ->
                    ( model, IL.scrollToNthItem NoOp "myList" idx config model.infList model.content )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


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
    div [] [ viewInput, viewList model ]


viewList : Model -> Html Msg
viewList model =
    div
        [ style "height" (String.fromInt containerHeight ++ "px")
        , style "width" "500px"
        , style "overflow" "auto"
        , style "border" "1px solid #000"
        , style "margin" "auto"
        , on "scroll" (JD.map OnScroll JD.value)
        , id "myList"
        ]
        [ IL.view config model.infList model.content ]


viewInput : Html Msg
viewInput =
    label []
        [ text "Scroll to:"
        , input [ onInput UserChangedScrollIndex ] []
        ]
