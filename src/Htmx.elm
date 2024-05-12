module Htmx exposing (..)

import Html
import Html.Attributes


{-| When the following custom element is defined, this wrapper lazy loads the htmx JS when this element appears on page.

No need to use this if you include the htmx JS in your project some other way.

    class HtmxTag extends HTMLElement {
        static htmxLoaded = false;
        async connectedCallback() {
            if (!HtmxTag.htmxLoaded) {
                HtmxTag.htmxLoaded = true;
                import('https://unpkg.com/htmx.org@1.9.12')
                .catch(error => console.error('Failed to load htmx module', error));
            }
        }
    }

    customElements.define('htmx', HtmxTag);

-}
lazyHtmx : Html msg -> Html msg
lazyHtmx html =
    Html.node "htmx" [] html



-- API for htmx attributes


{-| The hx-get attribute will cause an element to issue a GET to the specified URL and swap the HTML into the DOM using a swap strategy:

    <div hx-get="/example">Get Some HTML</div>

This example will cause the div to issue a GET to /example and swap the returned HTML into the innerHTML of the div.

Notes

  - hx-get is not inherited
  - By default hx-get does not include any parameters. You can use the hx-params attribute to change this
  - You can control the target of the swap using the hx-target attribute
  - You can control the swap strategy by using the hx-swap attribute
  - You can control what event triggers the request with the hx-trigger attribute
  - You can control the data submitted with the request in various ways, documented here: Parameters

-}
get : String -> Html.Attribute msg
get =
    Html.Attributes.attribute "hx-get"


{-| The hx-post attribute will cause an element to issue a POST to the specified URL and swap the HTML into the DOM using a swap strategy:

    <button hx-post="/account/enable" hx-target="body">
        Enable Your Account
    </button>

This example will cause the button to issue a POST to /account/enable and swap the returned HTML into the innerHTML of the body.

Notes

  - hx-post is not inherited
  - You can control the target of the swap using the hx-target attribute
  - You can control the swap strategy by using the hx-swap attribute
  - You can control what event triggers the request with the hx-trigger attribute
  - You can control the data submitted with the request in various ways, documented here: Parameters

-}
post : String -> Html.Attribute msg
post =
    Html.Attributes.attribute "hx-post"


swap : SwapValues -> Html.Attribute msg
swap =
    swapValueToString >> Html.Attributes.attribute "hx-swap"


{-| Values for Htmx.swap

InnerHTML - Replace the inner html of the target element
OuterHTML - Replace the entire target element with the response
Beforebegin - Insert the response before the target elementn
Afterbegin - Insert the response before the first child of the target element
Beforeend - Insert the response after the last child of the target element
Afterend - Insert the response after the target element
Delete - Deletes the target element regardless of the response
None - Does not append content from response (out of band items will still be processed).

-}
type SwapValues
    = InnerHTML
    | OuterHTML
    | BeforeBegin
    | AfterBegin
    | BeforeEnd
    | AfterEnd
    | Delete
    | None


swapValueToString : SwapValues -> String
swapValueToString swapValue =
    case swapValue of
        InnerHTML ->
            "innerHTML"

        OuterHTML ->
            "outerHTML"

        BeforeBegin ->
            "beforebegin"

        AfterBegin ->
            "afterbegin"

        BeforeEnd ->
            "beforeend"

        AfterEnd ->
            "afterend"

        Delete ->
            "delete"

        None ->
            "none"


trigger : String -> Html.Attribute msg
trigger =
    Html.Attributes.attribute "hx-trigger"
