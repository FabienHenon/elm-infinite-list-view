# elm-infinite-list-view [![Build Status](https://travis-ci.org/FabienHenon/elm-infinite-list-view.svg?branch=master)](https://travis-ci.org/FabienHenon/elm-infinite-list-view)

```
elm package install FabienHenon/elm-infinite-list-view
```

Infinite list allows you to display a virtual infinite list of items by only showing visible items on screen. This is very useful for
very long list of items.

This way, instead of showing you 100+ items, with this package you will only be shown maybe 20 depending on their height
and your configuration.

## How it works
A div element is using the full height of your entire list so that the scroll bar shows a long content.
Inside this element we show a few items to fill the parent element and we move them so that they are visible. Which items to show
is computed using the `scrollTop` value from the scroll event.

## Getting started

### Types
First you need to add infinite list to your messages and your model.

```elm
import InfiniteList

type Msg
    = InfiniteListMsg InfiniteList.Model

type alias Model =
    { infiniteList : InfiniteList.Model
    , longList : List String
    }
```

### Initialization
Initializes your model.

```elm
initModel : Model
initModel =
    { infiniteList = InfiniteList.init
    , longList = initialContent
    }
```

### Config
You will have to create a `Config` for your infinite list.

**Note** Your `Config` should _never_ be held in your model. It should only appear in your `view` code.

```elm
config : InfiniteList.Config String Msg
config =
    InfiniteList.config
        { itemView = itemView
        , itemHeight = InfiniteList.constantHeight 20
        , containerHeight = 500
        }
        |> InfiniteList.withOffset 300
        |> InfiniteList.withClass "my-class"


itemView : Int -> Int -> String -> Html Msg
itemView idx listIdx item =
    div [] [ text item ]

```

The `config` function needs a function to render your items, the items' height and the container's height (You don't have to know
the exact height. You can specify a greater height or the window's height. The more the height is, the more items will be displayed)

`itemView` is the function responsible of your items rendering. It takes 3 parameters:
  * index of the element to render
  * index of the item from your entire list
  * item to render

### View
Then, you need to do 2 things in your view:
  * Add the `onScroll` attribute
  * Add the list `view`

```elm
view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            , ( "overflow-x", "hidden" )
            , ( "overflow-y", "auto" )
            , ( "-webkit-overflow-scrolling", "touch" )
            ]
        , InfiniteList.onScroll InfiniteListMsg
        ]
        [ InfiniteList.view config model.infiniteList model.longList ]
```

You call `onScroll` on the element that must be scrolled and that contains your list. This function returns an `Attribute`.

**Your element must have a height explicitly set in order to have the scroll event triggered**

And then, inside this element, you call the `view` function, passing it the `config`, the `Model` and your long list.
It will render a placeholder `div` taking the height your entire list needs, and inside this element, it will render a container
_(that you can customize with `withCustomContainer`)_ that will contain the currently visible items of your list.

### Update
Finally, all we need to do is to implement the udpdate function.

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InfiniteListMsg infiniteList ->
            ( { model | infiniteList = infiniteList }, Cmd.none )
```

In the update you have to handle the infinite list message. This message contains the updated `Model` for the infinite list.

## Examples

To run the examples go to the `examples` directory, install dependencies and run `elm-reactor`:

```
> cd examples/
> elm package install
> elm-reactor
```
