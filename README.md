Social Faders
=============

Social faders provides a set of widgets designed for group control of an application.  The controls visually indicate who is setting what control value in real time by displaying the user's logged in social network picture.  Currently supports Google,Facebook,Twitter pictures.

Installation
------------
This module depends on collection2 and coffeescript.

If you install one of the supported accounts-* packages, users logged in via these services will
display their picture on the control when actively using it.

Usage
-----

Widgets are implemented as Handlebars helpers.

    {{verticalFader channel="volume1"}}
    {{horizontalFader channel="reverb2" width="200"}}

TODO:

    {{button channel="toggle3"}}
    {{pad channelX="x" channelY="y" points="3"}}

