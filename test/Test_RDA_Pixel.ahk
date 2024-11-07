class Test_RDA_Pixel {
  Begin() {
  }
  Test_8_Automation_PixelColors() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})
    win.setOpaque()

    color := win.getColor(50, 50)
    Yunit.assert(color == 0xF0F0F0, "notepad color at (50,50)")
    ; this should be the border...
    color := win.getColor(7, 7)
    ; this is flaky :S
    Yunit.assert(color == 0x6B6B6B || color == 0xA5A5A5, "notepad color at (7, 7)")
    ; this should be "minimize line"
    color := win.getColor(515, 15)
    Yunit.assert(color == 0x000000, "notepad color at (515, 15)")

    win.close()
  }

  Test_9_Automation_PixelSearch() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})
    win.move(50,50)
    win.resize(640, 480)

    position := win.searchColor(0x000000)
    color := position.getColor()
    Yunit.assert(color == 0x000000, "Found a back pixel at notepad")

    region := win.getRegion(0, 0, 50, 50)
    region.origin.set(position.x - 25, position.y - 25)
    region.origin.move(-25, -25)

    position2 := region.searchColor(0x000000)

    Yunit.assert(position.x == position2.x, "Found a pixel in the same position x")
    Yunit.assert(position.y == position2.y, "Found a pixel in the same position y")

    win.close()
  }


  Test_10_Automation_PixelAppearDisappear() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

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
