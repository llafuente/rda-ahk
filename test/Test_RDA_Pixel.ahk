class Test_RDA_Pixel {
  Begin() {
  }

  RDA_Get_SearchColor() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()

    Run % "mspaint.exe " . A_ScriptDir . "\dots-128x128.png"
    win := windows.waitOne({process: "mspaint.exe"})
    win.move(0, 0)
    win.resize(1024, 768)

    ;mouseMoveTo(50,200)
    color := win.getColor(50,200)
    Yunit.assert(color == 0x00FF00, "mspaint color at (50,200) is green")

    region := win.getRegion(50, 175, 25, 25)
    region.highlight(250)
    position := region.searchColor(0xFF0000)

    Yunit.assert(position.x != 0, "Found a pixel in the same position x")
    Yunit.assert(position.y != 0, "Found a pixel in the same position y")

    win.close()
  }

  RDA_WaitColor() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()

    Run % "mspaint.exe " . A_ScriptDir . "\green.png"

    win := windows.waitOne({process: "mspaint.exe"})
    win.move(50,50)
    win.resize(640, 480)

    pixel := win.pixel(200, 200)
    bgColor := pixel.getColor()
    Yunit.assert(bgColor == 0x00FF00, "mspaint bg is the green file")

    hide := ObjBindMethod(win, "hide")
    SetTimer % hide, 1000
    pixel.waitDisappearColor(bgColor, 2000)
    SetTimer % hide, Off


    show := ObjBindMethod(win, "show")
    SetTimer % show, 1000
    pixel.waitAppearColor(bgColor, 2000)
    SetTimer % show, Off

    ;pixel.mouseMove()
    ;sleep 10000
    win.close()
  }

  End() {
  }
}
