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
    win.resize(640, 480)

    pos := win.searchImage(A_ScriptDir . "\item.png", 4)
    Yunit.assert(pos.x == 90, "Image found at 90!")
    Yunit.assert(pos.y == 216, "Image found at 216!")

    hide := ObjBindMethod(win, "hide")
    SetTimer % hide, 1000
    ; note! hidden windows don't have a region, so it won't find the image
    ; use screen(1)
    idx := win.waitDisappearImage(A_ScriptDir . "\item.png", 4)
    RDA_Log_Debug(idx)
    Yunit.assert(idx == 1, "First image dissapear!")

    sleep 1000
    SetTimer % hide, Off

    show := ObjBindMethod(win, "show")
    SetTimer % show, 1000

    pos := automation.screen(1).waitAppearImage(A_ScriptDir . "\item.png", 4)
    Yunit.assert(pos.x == 90, "Image found at 90!")
    Yunit.assert(pos.y == 216, "Image found at 216!")

    SetTimer % show, Off


    win.close()
  }


  Test_13_Automation_Screenshot() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()

    Run % "mspaint.exe " . A_ScriptDir . "\search.png"

    win := windows.waitOne({process: "mspaint.exe"})
    win.move(50,50)
    win.resize(640, 480)
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

  End() {
  }
}
