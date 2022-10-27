SuperStrict

Import Text.xml
Import "src/TScreen.bmx"

Type TTileLayer
	Field width:Int
	Field height  :Int
	Field id:Int
	Field name:String
	Field data:Int[]
EndType

Type TTiledMap	
	' tileset image
	Field tilesImg:TImage
	
	' current directory where the *.TMX file was loaded from
	Field directory:String
	
	' map size
	Field width:Int	
	Field height:Int
	
	' tile layer data
	Field tileLayer:Int[]
	Field layerList:TList
	
	' tile size
	Field tileWidth:Int
	Field tileheight:Int
	
	' positions of each tile in the tileset
	Field tileSources:Int[]
	
	' XML root node
	Field rootNode:TxmlNode
	
	Method New()
		layerList = New TList
	EndMethod
	
	' load tiled TMX-File and also load the defined TSX-tileset and tileset image file
	Method LoadMap(filename:String)
		directory:String = ExtractDir(filename)
		Local mapXmlDoc:TxmlDoc = TxmlDoc.parseFile(filename)
		
		If mapXmlDoc Then
			rootNode = mapXmlDoc.getRootElement()		
			
			' get tile layer data
			If rootNode Then
				' get map size
				width = rootNode.GetAttribute("width").ToInt()
				height = rootNode.GetAttribute("height").ToInt()
				
				GetTileDataByLayerName("background")
			EndIf
			
			' get tileset
			Local node:TxmlNode = rootNode.findElement("tileset")
			If node Then				
				Local tilesetFilename:String = node.GetAttribute("source")
				ParseTsxFile(tilesetFilename)
			EndIf
		EndIf	
	
		mapXmlDoc.Free()
	EndMethod
	
	Method GetTileDataByLayerName(layerName:String)
		Local layerNode:TxmlNode = rootNode.findElement("layer")
		
		If layerNode Then			
			While(layerNode.getAttribute("name") <> layerName)
				layerNode = layerNode.nextSibling()
			Wend

			If layerNode.getAttribute("name") = layerName Then
				Local csv:TxmlNode = layerNode.findElement("data")
				
				If csv.GetAttribute("encoding") = "csv" Then
					GetCsvDataFromNode(csv)
				EndIf
			EndIf
		EndIf		
	EndMethod

	Method GetCsvDataFromNode(node:TxmlNode)
		Local csvString:String = node.getContent()		
		csvString = csvString.Replace(Chr(10), "")
		csvString:+ ","
		
		tileLayer = New Int[width * height]
		
		Local pos:Int = 1
		For Local y:Int = 0 To height - 1
			For Local x:Int = 0 To width - 1
				Local val:String = ""
				
				While(csvString[pos] <> 44)
					val:+ Chr(csvString[pos])
					pos:+1
				Wend
				
				tileLayer[x + (y * width)] = val.ToInt()
				pos:+1
			Next
		Next
	EndMethod
	
	Method ParseTsxFile(filename:String)
		Local tilesetXmlDoc:TxmlDoc = TxmlDoc.parseFile(Self.directory + "/" + filename)

		If tilesetXmlDoc Then
			Local tileSetRoot:TxmlNode = tilesetXmlDoc.getRootElement()
			
			' get tile size from tileset definition
			tileWidth = tileSetRoot.GetAttribute("tileheight").ToInt()
			tileHeight = tileSetRoot.GetAttribute("tileheight").ToInt()	
			
			' load tileset image
			Local tilesetNode:TxmlNode = tileSetRoot.findElement("image")
			If tilesetNode Then
				Local tilesetImageFilename:String = directory + "/" + tilesetNode.GetAttribute("source")
				tilesImg = LoadImage(tilesetImageFilename)
										
				Local tsWidth:Int = tilesetNode.GetAttribute("width").ToInt()
				Local tsHeight:Int = tilesetNode.GetAttribute("height").ToInt()
				
				CalculateTileSources(tsWidth, tsHeight)
			EndIf

			tilesetXmlDoc.Free()
		EndIf
	EndMethod	
	
	' calculate position of each tile in the tileset
	Method CalculateTileSources(width:Int, height:Int)
		If width > 0 Then width = width / tileWidth
		If height > 0 Then height = height / tileHeight
		tileSources = New Int[width * height * 2]
		
		Local c:Int = 0
		For Local y:Int = 0 To width - 1
			For Local x:Int = 0 To height - 1
				tileSources[c + 0] = x * tileWidth
				tileSources[c + 1] = y * tileHeight
				c:+2
			Next
		Next		
	EndMethod
	
	Method DrawTileLayer()
		For Local y:Int = 0 To height -1
			For Local x:Int = 0 To width - 1
				DrawSubImageRect(tilesImg, x * tileWidth, y * tileHeight, tileWidth, tileHeight, ..
								 16, 0, tileWidth, tileHeight)
			Next
		Next
	EndMethod
EndType


Init()

Global tiledMap:TTiledMap = New TTiledMap
Global screen:TScreen

tiledMap.LoadMap("data/levelmap.tmx")

Repeat
	Cls
	screen.Clear()
	'tiledMap.DrawTileLayer()
	'DrawImage(tiledMap.tilesImg, 10,10)
	Flip
Until KeyDown(KEY_ESCAPE)
End

Function Init()
	AppTitle = "tiled Map Demo"
	screen = TScreen.Create(480, 256)
EndFunction

Rem
Local li:TList = layerNode.getAttributeList()
For Local n:TxmlAttribute=EachIn li
	Print n.getName()
Next
EndRem