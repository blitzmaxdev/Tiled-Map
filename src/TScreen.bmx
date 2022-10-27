SuperStrict

Type TScreen
	Field width:Int
	Field height:Int
	Field posX:Int
	Field posY:Int
	Field scale:Float

	Method Init(width:Int, height:Int)
		Graphics DesktopWidth(), DesktopHeight(), DesktopDepth(), DesktopHertz()	
		AutoImageFlags MASKEDIMAGE
		Self.width = width
		Self.height = height	
		scale = DesktopHeight() / height		
		posX = (DesktopWidth() - (width * scale)) / 2
		posY = (DesktopHeight() - (height * scale)) / 2
		SetViewport(posX, posY, Int(width * scale), Int(height * scale))
	EndMethod
	
	Method Clear()	
		SetScale(scale, scale)
		SetColor(30, 30, 30)
		DrawRect(posX, posY, width, height)
		SetColor(255, 255, 255)
	EndMethod
	
	Method GetMousePosX:Int()
		Return (MouseX() - PosX) / scale
	EndMethod
	
	Method GetScale:Float()
		Return scale
	EndMethod	
	
	Method GetWidth:Int()
		Return width
	EndMethod
	
	Method GetHeight:Int()
		Return height
	EndMethod
	
	Function Create:TScreen(width:Int, height:Int)
		Local scr:TScreen = New TScreen
		scr.Init(width, height)
		Return scr
	EndFunction
EndType



