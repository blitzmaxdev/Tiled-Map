SuperStrict

Framework mky.mojo2
?Not opengles
Import brl.GLGraphics
?opengles
Import sdl.sdlgraphics
?
Import brl.pngloader

Import "src/TTiledMap.bmx"
Import "src/TDelta.bmx"

Type TScreen
	Global width:Int
	Global height:Int
	Global x:Int
	Global y:Int
	Global scale:Int
	Global canvas:TCanvas
	
	Function Init(_width:Int, _height:Int)
		width = _width
		height = _height
		scale = Floor(DesktopHeight() / height)
		x = ((DesktopWidth() - (width * scale)) / 2) / scale
		y = ((DesktopHeight() - (height * scale)) / 2) / scale
		Graphics DesktopWidth(), DesktopHeight(), DesktopDepth(), DesktopHertz()
		canvas = New TCanvas.CreateCanvas()
	EndFunction
	
	Function BeginDraw()
		canvas.clear(0, 0, 0)
		canvas.PushMatrix()
		canvas.scale(scale, scale)
	EndFunction
		
	Function EndDraw()
		canvas.PopMatrix()
		canvas.flush()
	EndFunction
EndType

' native game resolution
Const GAME_WIDTH:Int = 368
Const GAME_HEIGHT:Int = 256

Global gameScale:Int
Global tiledMap:TTiledMap

AppTitle = "tiled Map Demo"
TScreen.Init(GAME_WIDTH, GAME_HEIGHT)
HideMouse

' create new instance of a tiled map
tiledMap = TTiledMap.Create(GAME_WIDTH, GAME_HEIGHT)

' load tiled file
tiledMap.LoadTMX("data/levelmap.tmx")

' get tile layer data
tiledMap.GetTileDataByLayerName("items")
tiledMap.GetTileDataByLayerName("background")
tiledMap.GetTileDataByLayerName("bonus")

TDelta.Init()
	
Repeat	
	Local x:Float = tiledMap.GetX()
	Local y:Float = tiledMap.GetY()
	Local speed:Float = 60 * TDelta.dt
	If KeyDown(KEY_RIGHT) Then x:+speed 
	If KeyDown(KEY_LEFT) Then x:-speed
	If KeyDown(KEY_UP) Then y:-speed
	If KeyDown(KEY_DOWN) Then y:+speed

	If x <=0 Then x = 0
	If y <=0 Then y = 0
	tiledMap.SetPosition(x, y)
	
	' draw tile layer
	tiledMap.ClearCanvas()
	tiledMap.DrawTileLayer("background")
	tiledMap.DrawTileLayer("items")
	tiledMap.DrawTileLayer("bonus")
	
	TScreen.BeginDraw()
	TScreen.canvas.DrawRectImageSource(TScreen.x, TScreen.y, tiledMap.image, 0, 0, TScreen.width, TScreen.height)
	TScreen.canvas.DrawText(TDelta.dt, TScreen.x, TScreen.y)
	TScreen.EndDraw()

	TDelta.Update()		
	Flip
Until KeyDown(KEY_ESCAPE)
End