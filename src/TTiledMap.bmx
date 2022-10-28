SuperStrict

Import Text.xml
'Import "TScreen.bmx"

Type TTileLayer
	' layer size
	Field width:Int
	Field height:Int

	' layer id
	Field id:Int

	' layer name
	Field name:String

	' tile data
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
	Field canvas:TCanvas
	Field image:TImage
	
	' map position in pixel
	Field x:Float
	Field y:Float

	' tileset
	Field tileset:TTileset

	' current directory where the *.TMX file was loaded from
	Field directory:String
	
	' tile layer data
	Field tileLayer:Int[]
	Field layerList:TList
		
	' XML root node
	Field rootNode:TxmlNode
	
	' TMX Tiled file
	Field tmxFile:TxmlDoc

	Field width:Int
	Field height:Int
	
	Method Init(_width:Int, _height:Int)
		layerList = New TList
		tileset = New TTileset
		tmxFile = Null
		width = _width
		height = _height
		image = New TImage.Create(width+64, height+64, 0,0,0)
		canvas = New TCanvas.CreateCanvas(image)
	EndMethod
	
	Method SetPosition(x:Float, y:Float)
		Self.x = x
		Self.y = y
	EndMethod

	Method GetX:Float()
		Return x
	EndMethod

	Method GetY:Float()
		Return y 
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
	
	Method GetTileDataByLayerName(layerName:String)
		If tmxFile And rootNode Then
			Local tl:TTileLayer = New TTileLayer

			' get map size
			tl.width = rootNode.GetAttribute("width").ToInt()
			tl.height = rootNode.GetAttribute("height").ToInt()
			
			Local layerNode:TxmlNode = rootNode.findElement("layer")
			If layerNode Then			
				While(layerNode.getAttribute("name") <> layerName)
					layerNode = layerNode.nextSibling()
				Wend

				If layerNode.getAttribute("name") = layerName Then
					tl.name = layerNode.GetAttribute("name")
					Local csv:TxmlNode = layerNode.findElement("data")
					
					If csv.GetAttribute("encoding") = "csv" Then
						GetCsvDataFromNode(csv, tl)
					EndIf
				EndIf

				layerList.AddLast(tl)
			EndIf	
		EndIf
	EndMethod

	Method ClearCanvas()
		canvas.clear(0, 0, 0)
	EndMethod
	
	Method DrawTileLayer(layerName:String)
		Local startX:Int = Floor(x / tileset.width)
		Local startY:Int = Floor(y / tileset.height)

		Local softScrollX:Int = Floor(x Mod tileset.width)
		Local softScrollY:Int= Floor(y Mod tileset.height)

		Local layer:TTileLayer = FindTileLayerByName(layerName)

		If layer Then
			For Local y:Int = 0 To height / tileset.height
				For Local x:Int = 0 To width / tileset.width
					Local tileId:Int = layer.data[ (startX + x) + ( (y + startY) * layer.width)]
					
					If tileId > 0 Then
						Local sourceX:Int = tileset.positions[(tileId - 1) * 2]
						Local sourceY:Int = tileset.positions[(tileId - 1) * 2 + 1]
						
						Local destX:Int = (x * tileset.width) - softScrollX
						Local destY:Int = (y * tileset.height) - softScrollY

						canvas.DrawRectImageSource(destX, destY, tileset.image, sourceX, sourceY, tileset.width, tileset.height)
					EndIf
				Next
			Next
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
				tileset.image = TImage.Load(tilesetImageFilename)	
								
				' get dimension of the tileset and calculate x & y-position of each tile
				Local tsWidth:Int = tilesetNode.GetAttribute("width").ToInt()
				Local tsHeight:Int = tilesetNode.GetAttribute("height").ToInt()				
				CalculateTileSources(tsWidth, tsHeight)
			EndIf

			tilesetXmlDoc.Free()
		EndIf
	EndMethod	
	
	Method FindTileLayerByName:TTileLayer(name:String)
		Local retLayer:TTileLayer = Null

		For Local layer:TTileLayer = EachIn layerList
			If layer.name = name Then
				retLayer = layer
				Exit
			EndIf
		Next

		Return retLayer
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
			
	Function Create:TTiledMap(_width:Int, _height:Int)
		Local t:TTiledMap = New TTiledMap
		t.Init(_width, _height)
		Return t
	EndFunction
EndType
