class Test_RDA_Image {
  Begin() {
  }


  Test_12_Automation_ImageSearch() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()

    Run % "mspaint.exe " . A_ScriptDir . "\search.png"

    win := windows.waitOne({process: "mspaint.exe"})
    win.move(50,50)
    win.resize(1024, 768)
    imagePath := A_ScriptDir . "\item.png"
    pos := win.searchImage(imagePath, 4)
    Yunit.assert(pos.x > 0, "Image found at x = 269!")
    Yunit.assert(pos.y > 0, "Image found at y = 274!")

    startTime := A_TickCount
    hide := ObjBindMethod(win, "hide")
    SetTimer % hide, 1000
    ; note! hidden windows don't have a region, so it won't find the image

    ; use screen(1)
    result := win.waitDisappearImage(imagePath, 4)
    Yunit.assert(result.x == -1, "check result.x value")
    Yunit.assert(result.y == -1, "check result.y value")
    Yunit.assert(result.image == imagePath, "check result.image value")
    Yunit.assert(A_TickCount - startTime > 1000, "Elapsed at least 1000 ms")

    SetTimer % hide, Off

    show := ObjBindMethod(win, "show")
    SetTimer % show, 1000

    result2 := automation.screen(1).waitAppearImage(A_ScriptDir . "\item.png", 4)
    Yunit.assert(result2.x > 0, "check result2.x value")
    Yunit.assert(result2.y > 0, "check result2.y value")
    Yunit.assert(result2.image == imagePath, "check result2.image value")

    SetTimer % show, Off


    win.close()
  }
/*

  Test_13_Automation_Screenshot() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()

    Run % "mspaint.exe " . A_ScriptDir . "\search.png"

    win := windows.waitOne({process: "mspaint.exe"})
    win.move(50,50)
    win.resize(1024, 768)
    win.mouseMoveTo(150, 105)
    try {
      FileDelete % A_ScriptDir . "\test-mspaint.png"
    } catch e {
    }
    win.screenshot(A_ScriptDir . "\test-mspaint.png", true)

    Yunit.assert(fileExist(A_ScriptDir . "\test-mspaint.png"), "Image found at 216!")

    try {
      FileDelete % A_ScriptDir . "\test-mspaint.png"
    } catch e {
    }

    win.close()
  }
*/
  End() {
  }
}
