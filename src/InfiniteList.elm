module InfiniteList exposing
    ( init
    , config, withConstantHeight, withVariableHeight
    , onScroll
    , view
    , withOffset, withCustomContainer, withClass, withStyles, withId
    , updateScroll
    , Model, Config, ItemHeight
    , scrollToNthItem
    )

{-| Displays a virtual infinite list of items by only showing visible items on screen. This is very useful for
very long list of items.

This way, instead of showing you 100+ items, with this package you will only be shown maybe 20 depending on their height
and your configuration.

**How it works**: A div element is using the full height of your entire list so that the scroll bar shows a long content.
Inside this element we show a few items to fill the parent element and we move them so that they are visible. Which items to show
is computed using the `scrollTop` value from the scroll event.


# Initialization

@docs init


# Configuration

@docs config, withConstantHeight, withVariableHeight


# Scroll

@docs onScroll


# View

@docs view


# Customization

@docs withOffset, withCustomContainer, withClass, withStyles, withId


# Advanced

@docs updateScroll


# Types

@docs Model, Config, ItemHeight

-}

import Browser.Dom as Dom
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Html.Events exposing (on)
import Html.Lazy exposing (lazy3)
import Json.Decode as JD
import Task


{-| Model of the infinite list module. You need to create a new one using `init` function.
-}
type Model
    = Model Int


{-| Configuration for your infinite list, describing the look and feel.
**Note:** Your `Config` should _never_ be held in your model.
It should only appear in `view` code.
-}
type Config item msg
    = Config (ConfigInternal item msg)


type alias ConfigInternal item msg =
    { itemHeight : ItemHeight item
    , itemView : Int -> Int -> item -> Html msg
    , containerHeight : Int
    , offset : Int
    , customContainer : List ( String, String ) -> List (Html msg) -> Html msg
    , id : Maybe String
    , styles : List ( String, String )
    , class : Maybe String
    }


{-| Item height description
-}
type ItemHeight item
    = Constant Int
    | Variable (Int -> item -> Int)


{-| Creates a new `Model`.

    initModel : Model
    initModel =
        { infiniteList = InfiniteList.init }

-}
init : Model
init =
    Model 0


{-| Creates a new `Config`. This function will need a few mandatory parameters
and you will be able to customize it more with `with...` functions

    config : InfiniteList.Config String msg
    config =
        InfiniteList.config
            { itemView = itemView
            , itemHeight = InfiniteList.withConstantHeight 20
            , containerHeight = 300
            }

    itemView : Int -> Int -> String -> Html Msg
    itemView idx listIdx item =
        -- view code

The `itemView` parameter is the function used to render each item of your list.
Parameters of this function are

  - current index of the element currently displayed
  - index of the item in the entire list (their real index in your entire list)
  - item to render

**Note**: If you can't know the exact container's height it's not a problem. Just
specify a height you are sure is greater than the maximum possible container's height.
You can also specify the window's height.
Having a height greater than the actual container's height will just make you show a little more items than
if you specified the exact container's height.

-}
config :
    { itemView : Int -> Int -> item -> Html msg
    , itemHeight : ItemHeight item
    , containerHeight : Int
    }
    -> Config item msg
config conf =
    Config
        { itemHeight = conf.itemHeight
        , containerHeight = conf.containerHeight
        , offset = 200
        , itemView = conf.itemView
        , customContainer = defaultContainer
        , styles = []
        , class = Nothing
        , id = Nothing
        }


{-| Specifies that the items' height will always be the same.
This function needs the height of the items

    config : InfiniteList.Config String msg
    config =
        InfiniteList.config
            { itemView = itemView
            , itemHeight = InfiniteList.withConstantHeight 20
            , containerHeight = 300
            }

-}
withConstantHeight : Int -> ItemHeight item
withConstantHeight height =
    Constant height


{-| Specifies that the items' height will change according to the item.
This function needs a function taking the index of the item in your list of items, and the current item.
It must return the item's height

    config : InfiniteList.Config String msg
    config =
        InfiniteList.config
            { itemView = itemView
            , itemHeight = InfiniteList.withVariableHeight getItemHeight
            , containerHeight = 300
            }

    getItemHeight : Int -> String -> Int
    getItemHeight idx item =
        if remainderBy 2 idx == 0 then
            20

        else
            40

-}
withVariableHeight : (Int -> item -> Int) -> ItemHeight item
withVariableHeight getHeight =
    Variable getHeight


{-| Changes the default offset.

The offset is a value that represents a _margin_ at the top and bottom of the container so that
items will be displayed up to these margins.

This avoids showing blank spaces as you scroll.

The default value is 200px. If you want more margin, you can specify a greater value, but be careful as it will
display more items on screen.

-}
withOffset : Int -> Config item msg -> Config item msg
withOffset offset (Config value) =
    Config
        { value | offset = offset }


{-| Specifies a class to set to the top container `div`.
-}
withClass : String -> Config item msg -> Config item msg
withClass class (Config value) =
    Config
        { value | class = Just class }


{-| Specifies an id to set to the top container `div`.
-}
withId : String -> Config item msg -> Config item msg
withId id (Config value) =
    Config
        { value | id = Just id }


{-| Specifies styles to set to the top container `div`.

This module also specified styles that may override yours.

-}
withStyles : List ( String, String ) -> Config item msg -> Config item msg
withStyles styles (Config value) =
    Config
        { value | styles = styles }


{-| Specifies a custom container to use instead of the default `div` one inside the top `div` container.
The function to pass takes a list of styles you will have to apply, and a list of children (your items) you will have to display (See example below).

The default structure of this infinite list is:

    div
        -- Top container --
        []
        [ div
            -- Items container --
            []
            [ items ]
        ]

For instance, if you want to display a list (`li` elements) you prably want to replace the default `div` container
by an `ul` element.
Here is how to do:

    InfiniteList.withCustomContainer customContainer config

    customContainer : List (String, String) -> List (Html msg) -> Html msg
    customContainer styles children =
        ul [ style styles ] children

-}
withCustomContainer : (List ( String, String ) -> List (Html msg) -> Html msg) -> Config item msg -> Config item msg
withCustomContainer customContainer (Config value) =
    Config
        { value | customContainer = customContainer }


{-| This function returns the `onScroll` attribute to be added to the attributes of
your infinite list container.

    type Msg
        = InfiniteListMsg InfiniteList.Model

    view : Model -> Html Msg
    view model =
        div
            [ style "width" "100%"
            , style "height" "100%"
            , style "overflow-x" "hidden"
            , style "overflow-y" "auto"
            , style "-webkit-overflow-scrolling" "touch"
            , InfiniteList.onScroll InfiniteListMsg
            ]
            [ InfiniteList.view config model.infiniteList list ]

-}
onScroll : (Model -> msg) -> Html.Attribute msg
onScroll scrollMsg =
    on "scroll" (decodeScroll scrollMsg)


{-| **Only use this function if you handle `on "scroll"` event yourself**
_(for instance if another package is also using the scroll event on the same node)_

You have to pass it a `Json.Decode.Value` directly coming from `on "scroll"` event you handle, and the `Model`.
It returns the updated `Model`

    type Msg
        = OnScroll JsonDecoder.Value

    view : Model -> Html Msg
    view model =
        div
            [ style "width" "100%"
            , style "height" "100%"
            , style "overflow-x" "hidden"
            , style "overflow-y" "auto"
            , style "-webkit-overflow-scrolling" "touch"
            , on "scroll" (JsonDecoder.map OnScroll JsonDecoder.value)
            ]
            [ InfiniteList.view config model.infiniteList list ]

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            -- ... --
            OnScroll value ->
                ( { model | infiniteList = InfList.updateScroll value model.infiniteList }, Cmd.none )

-}
updateScroll : JD.Value -> Model -> Model
updateScroll value (Model model) =
    case JD.decodeValue decodeToModel value of
        Ok m ->
            m

        Err _ ->
            init



-- View


{-| Function used to display your long list

**The element's height must be explicitly set, otherwise scroll event won't be triggered**

    config : InfiniteList.Config String Msg
    config =
        InfiniteList.config
            { itemView = itemView
            , itemHeight = InfiniteList.withConstantHeight 20
            , containerHeight = 300
            }

    itemView : Int -> Int -> String -> Html Msg
    itemView idx listIdx item =
        div [] [ text item ]

    view : Model -> Html Msg
    view model =
        div
            [ style "width" "100%"
            , style "height" "100%"
            , style "overflow-x" "hidden"
            , style "overflow-y" "auto"
            , style "-webkit-overflow-scrolling" "touch"
            , InfiniteList.onScroll InfiniteListMsg
            , id "myslist" -- set an HTML id if you want to use scrollToNthItem later
            ]
            [ InfiniteList.view config model.infiniteList list ]

-}
view : Config item msg -> Model -> List item -> Html msg
view configValue model list =
    lazy3 lazyView configValue model list


type alias Calculation item =
    { skipCount : Int
    , elements : List item
    , topMargin : Int
    , totalHeight : Int
    }


lazyView : Config item msg -> Model -> List item -> Html msg
lazyView ((Config { itemView, customContainer }) as configValue) (Model scrollTop) items =
    let
        { skipCount, elements, topMargin, totalHeight } =
            computeElementsAndSizes configValue scrollTop items

        elementsCountToSkip =
            skipCount

        elementsToShow =
            elements
    in
    div
        (attributes totalHeight configValue)
        [ customContainer
            [ ( "margin", "0" )
            , ( "padding", "0" )
            , ( "box-sizing", "border-box" )
            , ( "top", String.fromInt topMargin ++ "px" )
            , ( "position", "relative" )
            ]
            (List.indexedMap (\idx item -> lazy3 itemView idx (elementsCountToSkip + idx) item) elementsToShow)
        ]


computeElementsAndSizes : Config item msg -> Int -> List item -> Calculation item
computeElementsAndSizes ((Config { itemHeight, itemView, customContainer }) as configValue) scrollTop items =
    case itemHeight of
        Constant height ->
            computeElementsAndSizesForSimpleHeight configValue height scrollTop items

        Variable function ->
            computeElementsAndSizesForMultipleHeights configValue function scrollTop items


{-| Function used to change the list scrolling from your program, so that the nth item of the list is displayed on top
-}
scrollToNthItem :
    { postScrollMessage : msg
    , listHtmlId : String
    , itemIndex : Int
    , configValue : Config item msg
    , items : List item
    }
    -> Cmd msg
scrollToNthItem { postScrollMessage, listHtmlId, itemIndex, configValue, items } =
    Dom.setViewportOf listHtmlId 0 (firstNItemsHeight itemIndex configValue items)
        |> Task.attempt (\_ -> postScrollMessage)


firstNItemsHeight : Int -> Config item msg -> List item -> Float
firstNItemsHeight idx configValue items =
    let
        { totalHeight } =
            computeElementsAndSizes configValue 0 (List.take idx items)
    in
    toFloat totalHeight


defaultContainer : List ( String, String ) -> List (Html msg) -> Html msg
defaultContainer styles elements =
    div (styles |> List.map (\( attr, value ) -> style attr value)) elements


attributes : Int -> Config item msg -> List (Html.Attribute msg)
attributes totalHeight (Config { styles, id, class }) =
    (styles
        ++ [ ( "margin", "0" )
           , ( "padding", "0" )
           , ( "box-sizing", "border-box" )
           , ( "height", String.fromInt totalHeight ++ "px" )
           , ( "width", "100%" )
           ]
    )
        |> List.map (\( attr, value ) -> style attr value)
        |> addAttribute Html.Attributes.id id
        |> addAttribute Html.Attributes.class class


addAttribute : (a -> Html.Attribute msg) -> Maybe a -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addAttribute f value newAttributes =
    case value of
        Nothing ->
            newAttributes

        Just v ->
            f v :: newAttributes



-- Computations


computeElementsAndSizesForSimpleHeight : Config item msg -> Int -> Int -> List item -> Calculation item
computeElementsAndSizesForSimpleHeight (Config { offset, containerHeight }) itemHeight scrollTop items =
    let
        elementsCountToShow =
            (offset * 2 + containerHeight) // itemHeight + 1

        elementsCountToSkip =
            max 0 ((scrollTop - offset) // itemHeight)

        elementsToShow =
            (List.drop elementsCountToSkip >> List.take elementsCountToShow) items

        topMargin =
            elementsCountToSkip * itemHeight

        totalHeight =
            List.length items * itemHeight
    in
    { skipCount = elementsCountToSkip, elements = elementsToShow, topMargin = topMargin, totalHeight = totalHeight }


computeElementsAndSizesForMultipleHeights : Config item msg -> (Int -> item -> Int) -> Int -> List item -> Calculation item
computeElementsAndSizesForMultipleHeights (Config { offset, containerHeight }) getHeight scrollTop items =
    let
        updateComputations item calculatedTuple =
            let
                { idx, elementsCountToSkip, elementsToShow, topMargin, currentHeight } =
                    calculatedTuple

                height =
                    getHeight idx item

                newCurrentHeight =
                    currentHeight + height
            in
            -- If still below limit, we skip it
            if newCurrentHeight <= (scrollTop - offset) then
                { calculatedTuple | idx = idx + 1, elementsCountToSkip = elementsCountToSkip + 1, topMargin = topMargin + height, currentHeight = newCurrentHeight }

            else if currentHeight < (scrollTop + containerHeight + offset) then
                { calculatedTuple | idx = idx + 1, elementsToShow = item :: elementsToShow, currentHeight = newCurrentHeight }

            else
                { calculatedTuple | idx = idx + 1, currentHeight = newCurrentHeight }

        initialValue =
            { idx = 0
            , elementsCountToSkip = 0
            , elementsToShow = []
            , topMargin = 0
            , currentHeight = 0
            }

        computedValues =
            List.foldl updateComputations initialValue items
    in
    { skipCount = computedValues.elementsCountToSkip
    , elements = List.reverse computedValues.elementsToShow
    , topMargin = computedValues.topMargin
    , totalHeight = computedValues.currentHeight
    }



-- Decoder


decodeToModel : JD.Decoder Model
decodeToModel =
    JD.at [ "target", "scrollTop" ] JD.int |> JD.map Model


decodeScroll : (Model -> msg) -> JD.Decoder msg
decodeScroll scrollMsg =
    JD.map (\s -> scrollMsg s) decodeToModel
