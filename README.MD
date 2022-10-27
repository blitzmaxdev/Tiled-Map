<h1> simple Tiled loader </h1>
<p>
brings Tiled maps to your BlitzMAX NG projects.
</p>

<p>
still under development.
</p>

<p>
how to use:<br>
 "TScreen" user defined type, represents the game screen.<br>
 "TTiledMap" user defined type, represents the tilemap.<br>
<ul>
<li>call <code>TScreen.Create(width:int, height:int)</code> function to create an instance for a game screen</li>
<li>call <code>TTiledMap.Create()</code> function to create an instance for a tilemap.</li>
<li>use <code>loadTMX(filename:String)</code> method to load an Tiled-TMX file. There must also an *.TSX file in the same directory.</li>
<li>call the <code>GetTileDataByLayerName(layerName:String)</code> method of the TTiledMap instance to get the CSV tilemap data from a specific tile layer.</li>
<li>call the <code>clear</code> method of the "Screen" instance to start drawing with the correct scale and position.</li>
<li>use the <code>DrawTileLayer(screen:TScreen, layerName:String)</code> method on the "TTiledMap" instance to draw a specific tile layer.</li>
</ul>

</p>

<p>
Get BlitzMAX NG <a href="https://blitzmax.org/">here</a>
</p>