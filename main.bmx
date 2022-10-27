SuperStrict

Import "src/TScreen.bmx"
Import "src/TTiledMap.bmx"

Global tiledMap:TTiledMap
Global screen:TScreen

Init()

Repeat
	screen.Clear()
	tiledMap.DrawTileLayer(screen)
	Flip
Until KeyDown(KEY_ESCAPE)
End

Function Init()
	AppTitle = "tiled Map Demo"
	screen = TScreen.Create(480, 256)
	tiledMap = TTiledMap.Create()
	
	tiledMap.LoadMap("data/levelmap.tmx")
	HideMouse
EndFunction