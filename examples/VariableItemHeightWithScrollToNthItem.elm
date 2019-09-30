module VariableItemHeight exposing (main)

import Browser
import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onInput)
import InfiniteList as IL


type Msg
    = InfListMsg IL.Model
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
        InfListMsg infList ->
            ( { model | infList = infList }, Cmd.none )

        UserChangedScrollIndex string ->
            case String.toInt string of
                Just idx ->
                    ( model
                    , IL.scrollToNthItem
                        { postScrollMessage = NoOp
                        , listHtmlId = "myList"
                        , itemIndex = idx
                        , configValue = config
                        , items = model.content
                        }
                    )

                Nothing ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


itemHeight : Int -> String -> Int
itemHeight idx item =
    if remainderBy 2 idx == 0 then
        20

    else
        40


containerHeight : Int
containerHeight =
    500


config : IL.Config String Msg
config =
    IL.config
        { itemView = itemView
        , itemHeight = IL.withVariableHeight itemHeight
        , containerHeight = containerHeight
        }
        |> IL.withOffset 300


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    div
        [ style "height" (String.fromInt (itemHeight listIdx item) ++ "px")
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
        , IL.onScroll InfListMsg
        , id "myList"
        ]
        [ IL.view config model.infList model.content ]


viewInput : Html Msg
viewInput =
    label []
        [ text "Scroll to:"
        , input [ onInput UserChangedScrollIndex ] []
        ]
