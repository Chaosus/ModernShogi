## What is this game about ?

Its an advanced japanese chess client with 3D board, AI, server-based multiplayer and more !

Features:

-Lots of piece, UI and board themes
-Lots of handicap and timer options(in development)
-Replay viewing(currently only KIF format supported)
-Auto-show moves when you hover your mouse cursor over piece
-Showing dangers and protections on tiles
-Auto-move in one-click if piece have only one move
-Auto-promotion for some pieces
-Speech for turn announcing
-Try-rule or 28-piece rule for impasse
-Modern multiplayer experience with remote master server

## This is source code and where can I download game binary ?

https://chaosus.itch.io/modern-shogi - Its better to download directly through itch.io client

## Is this game free ? What kind of License ? 

Yes its completly free. You can create your derivative work or contribute to main project. Source code is licensed under MIT license. If you want to help developer you can subscribe to my patreon - (https://www.patreon.com/chaosus). 

## Which languages in-game will be supported ?

English and Russian. I wish to support Japanese and Chinese in future.

## What kind of shogi game types is supported now ?

Classic 9x9 shogi for now(with several handicaps). But I plan to add more variants of shogi later. 

## What kind of gameplay options game currently have ?

You can play against AI, other player on same computer, view replays(in KIF format) or play with other players through master server.

## What about AI ?

Game uses YaneuraOu engine(https://github.com/yaneurao/YaneuraOu) and evaluation book Elmo(https://github.com/mk-takizawa/elmo_for_learn) (https://drive.google.com/file/d/0B0XpI3oPiCmFalVGclpIZjBmdGs) - latest version from 2018/5. You should download them or compile yourself if you want to develop AI. Place them in "engines" folder in resulted binary folder. 

## Why do you use Godot ? Why not Unity or Unreal Engine 4 ?

Unity have an ugly and small UI interface, and C# API in Unity is ugly too.
UE4 is overcomplicated and does not have comfortable(for me) script language.
Godot gives me required level of power from box.
