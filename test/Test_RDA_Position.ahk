class Test_RDA_Position {
  Begin() {
  }

  Test_RDA_Position_Interface() {
    local
    global Yunit, RDA_Automation, RDA_ScreenPosition, RDA_WindowPosition
    ; check WindowPosition and ScreenPosition has the same interface

    automation := new RDA_Automation()
    windows := automation.windows()
    Yunit.assert(windows.automation != 0, "windows has automation property")

    ; win := windows.get()[1]
    screenMethods := []
    for k,v in RDA_ScreenPosition {
      screenMethods.push(k)
    }
    windowMethods := []
    for k,v in RDA_WindowPosition {
      windowMethods.push(k)
    }
    diff := ArrayDiff(screenMethods, windowMethods)
    RDA_Log_Debug(diff)
    Yunit.assert(diff.length() == 4, "Missing some methods")
  }


  End() {
  }
}
