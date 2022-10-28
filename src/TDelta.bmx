' this delta time is from: https://www.blitzmax.org/docs/en/tutorials/beginners_guide/
Type TDelta
    Global dt:Float
    Global timeDelay:Int

    ' call this function before your game loop
    Function Init()
        timeDelay = MilliSecs()
    End Function

    ' call this in your game loop
    Function Update()
        dt = (MilliSecs() - timeDelay) * 0.001
        timeDelay = MilliSecs()
    End Function
End Type