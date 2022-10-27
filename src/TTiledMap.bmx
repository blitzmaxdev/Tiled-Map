SuperStrict

Import Text.xml
Import "TScreen.bmx"

Type TTileLayer
	Field width:Int
	Field height:Int
	Field id:Int
	Field name:String
	Field data:Int[]
EndType

Type TTileset
	' tileset image
	Field image:TImage
	
	' tile size
	Field width:Int
	Field height:Int
	
	' positions of each tile in the tileset
	Field positions:Int[]
EndType

Type TTiledMap	
	Field tileset:TTileset

	' current directory where the *.TMX file was loaded from
	Field directory:String
	
	' map size
	Field width:Int	
	Field height:Int
	
	' tile layer data
	Field tileLayer:Int[]
	Field layerList:TList
		
	' XML root node
	Field rootNode:TxmlNode
	
	' TMX Tiled file
	field tmxFile:TxmlDoc

	Method New()
		layerList = New TList
		tileset = New TTileset
		tmxFile = null
	EndMethod
	
	' load tiled TMX-File and also load the defined TSX-tileset and tileset image file
	Method LoadTMX(filename:String)
		directory:String = ExtractDir(filename)
		tmxFile:TxmlDoc = TxmlDoc.parseFile(filename)
		
		If tmxFile Then
			rootNode = tmxFile.getRootElement()		
				
			' get tileset
			Local node:TxmlNode = rootNode.findElement("tileset")
			If node Then				
				Local tilesetFilename:String = node.GetAttribute("source")
				ParseTsxFile(tilesetFilename)
			EndIf
		EndIf	
	EndMethod
	
	Method FindTileLayerByName:TTileLayer(layerName:String)
		local retLayer:TTileLayer = Null

		For Local layer:TTileLayer = EachIn layerList
			If layer.name = layerName Then
				retLayer = layer
				Exit
			EndIf
		Next

		return retLayer
	EndMethod

	Method GetTileDataByLayerName(layerName:String)
		If tmxFile And rootNode Then
			local tl:TTileLayer = new TTileLayer
			layerList.AddLast(tl)

			' get map size
			tl.width = rootNode.GetAttribute("width").ToInt()
			tl.height = rootNode.GetAttribute("height").ToInt()

			Local layerNode:TxmlNode = rootNode.findElement("layer")
			tl.name = layerNode.GetAttribute("name")

			If layerNode Then			
				While(layerNode.getAttribute("name") <> layerName)
					layerNode = layerNode.nextSibling()
				Wend

				If layerNode.getAttribute("name") = layerName Then
					Local csv:TxmlNode = layerNode.findElement("data")
					
					If csv.GetAttribute("encoding") = "csv" Then
						GetCsvDataFromNode(csv, tl)
					EndIf
				EndIf
			EndIf	
		EndIf
	EndMethod

	Method GetCsvDataFromNode(node:TxmlNode, tileLayer:TTileLayer)
		Local csvString:String = node.getContent()		
		csvString = csvString.Replace(Chr(10), "")
		csvString:+ ","
		
		tileLayer.data = New Int[tileLayer.width * tileLayer.height]
		
		Local pos:Int = 1
		For Local y:Int = 0 To tileLayer.height - 1
			For Local x:Int = 0  To tileLayer.width - 1
				Local val:String = ""
				
				While(csvString[pos] <> 44)
					val:+ Chr(csvString[pos])
					pos:+1
				Wend
				
				tileLayer.data[x + (y * tileLayer.width)] = val.ToInt()
				pos:+1
			Next
		Next
	EndMethod
	
	Method ParseTsxFile(filename:String)
		Local tilesetXmlDoc:TxmlDoc = TxmlDoc.parseFile(Self.directory + "/" + filename)

		If tilesetXmlDoc Then
			Local tileSetRoot:TxmlNode = tilesetXmlDoc.getRootElement()
			
			' get tile size from tileset definition
			tileset.width = tileSetRoot.GetAttribute("tileheight").ToInt()
			tileset.height = tileSetRoot.GetAttribute("tileheight").ToInt()	
			
			' load tileset image
			Local tilesetNode:TxmlNode = tileSetRoot.findElement("image")
			If tilesetNode Then
				Local tilesetImageFilename:String = directory + "/" + tilesetNode.GetAttribute("source")
				tileset.image = LoadImage(tilesetImageFilename)
										
				' get dimension of the tileset and calculate x & y-position of each tile
				Local tsWidth:Int = tilesetNode.GetAttribute("width").ToInt()
				Local tsHeight:Int = tilesetNode.GetAttribute("height").ToInt()				
				CalculateTileSources(tsWidth, tsHeight)
			EndIf

			tilesetXmlDoc.Free()
		EndIf
	EndMethod	
	
	' calculate position of each tile in the tileset
	Method CalculateTileSources(width:Int, height:Int)
		If width > 0 Then width = width / tileset.width
		If height > 0 Then height = height / tileset.height
		tileset.positions = New Int[width * height * 2]
		
		Local c:Int = 0
		For Local y:Int = 0 To width - 1
			For Local x:Int = 0 To height - 1
				tileset.positions[c + 0] = x * tileset.width
				tileset.positions[c + 1] = y * tileset.height
				c:+2
			Next
		Next		
	EndMethod
	
	Method DrawTileLayer(screen:TScreen, tileLayer:TTileLayer)
		Local scale:Int = screen.GetScale()
		
		For Local y:Int = 0 To screen.GetHeight() / tileset.height - 1
			For Local x:Int = 0 To screen.GetWidth() / tileset.width - 1
				Local tileId:Int = tileLayer.data[x + (y * tileLayer.width)]
				
				If tileId > 0 Then
					Local sourceX:Int = tileset.positions[(tileId - 1) * 2]
					Local sourceY:Int = tileset.positions[(tileId - 1) * 2 + 1]
					
					DrawSubImageRect(tileset.image,
									screen.GetPosX() + (x * tileset.width * scale),
									screen.GetPosY() + (y * tileset.height * scale),
									tileset.width, tileset.height,
									sourceX, sourceY, tileset.width, tileset.height)
				EndIf
			Next
		Next
	EndMethod
		
	Function Create:TTiledMap()
		Return New TTiledMap
	EndFunction
EndType