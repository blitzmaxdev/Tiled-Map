SuperStrict

Import "src/TScreen.bmx"
Import "src/TTiledMap.bmx"

Global screen:TScreen
Global tiledMap:TTiledMap

AppTitle = "tiled Map Demo"
screen = TScreen.Create(480, 256)
HideMouse

' create new instance of a tiled map
tiledMap = TTiledMap.Create()

' load tiled file
tiledMap.LoadTMX("data/levelmap.tmx")
tiledMap.GetTileDataByLayerName("items")
tiledMap.GetTileDataByLayerName("background")
tiledMap.GetTileDataByLayerName("bonus")

Repeat
	screen.Clear()
	tiledMap.DrawTileLayer(screen, "background")
	tiledMap.DrawTileLayer(screen, "items")
	tiledMap.DrawTileLayer(screen, "bonus")
	Flip
Until KeyDown(KEY_ESCAPE)
End