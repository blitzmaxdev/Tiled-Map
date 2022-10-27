SuperStrict

Import "src/TScreen.bmx"
Import "src/TTiledMap.bmx"
import "src/TDelta.bmx"

Global screen:TScreen
Global tiledMap:TTiledMap

AppTitle = "tiled Map Demo"
screen = TScreen.Create(480, 256)
HideMouse

' create new instance of a tiled map
tiledMap = TTiledMap.Create()

' load tiled file
tiledMap.LoadTMX("data/levelmap.tmx")

' get tile layer data
tiledMap.GetTileDataByLayerName("items")
tiledMap.GetTileDataByLayerName("background")
tiledMap.GetTileDataByLayerName("bonus")

TDelta.Start()

Repeat
	screen.Clear()

	' draw tile layer
	tiledMap.DrawTileLayer(screen, "background")
	tiledMap.DrawTileLayer(screen, "items")
	tiledMap.DrawTileLayer(screen, "bonus")

	local x:float = tiledMap.GetX()
	local y:float = tiledMap.GetY()
	local speed:Float = 30 * TDelta.GetTime()
	If KeyDown(KEY_RIGHT) Then x:+speed 
	If KeyDown(KEY_LEFT) Then x:-speed
	If KeyDown(KEY_UP) Then y:-speed
	If KeyDown(KEY_DOWN) Then y:+speed

	if x <=0 then x = 0
	if y <=0 then y = 0
	tiledMap.SetPosition(x, y)

	TDelta.Update()
	Flip
Until KeyDown(KEY_ESCAPE)
End