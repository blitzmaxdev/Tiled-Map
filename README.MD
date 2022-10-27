<h1> simple Tiled loader </h1>
<p>
brings Tiled maps to your BlitzMAX NG projects.
</p>

<p>
still under development.
</p>

<p>
how to use:
 "TScreen" user defined type, represents the game screen.
<ul>
<li>call TScreen.Create(width:int, height:int) function to create an instance for a game screen</li>
<li>call TTiledMap.Create() function to create an instance for a tilemap.</li>
<li>use "loadTMX(filename:String)" method to load an Tiled-TMX file. There must also an *.TSX file in the same directory.</li>
<li>call the "GetTileDataByLayerName(layerName:String)" method of the TTiledMap instance to get the CSV tilemap data from a specific tile layer.</li>
<li>call the "clear" method of the "Screen" instance to start drawing with the correct scale and position.</li>
<li>use the "DrawTileLayer(screen:TScreen, layerName:String)" method on the "TTiledMap" instance to draw a specific tile layer.</li>
</ul>

</p>

<p>
Get BlitzMAX NG <a href="https://blitzmax.org/">here</a>
</p>