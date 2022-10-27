' this delta time is from: https://www.blitzmax.org/docs/en/tutorials/beginners_guide/
Type TDelta
    Global DeltaTime:Float
    Global TimeDelay:Int

    ' call this function before your game loop
    Function Start()
        TimeDelay = MilliSecs()
    End Function

    Function GetTime:Float()
        Return DeltaTime
    End Function

    ' call this in your game loop
    Function Update()
        DeltaTime = (MilliSecs()- TimeDelay) * 0.001
        TimeDelay = MilliSecs()
    End Function
End Type