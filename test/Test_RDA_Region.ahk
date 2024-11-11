class Test_RDA_Region {
  Begin() {
  }

  Test_5_Automation_Region() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    Yunit.assert(windows.automation != 0, "windows has automation property")
    mouse := automation.mouse()
    Yunit.assert(mouse.automation != 0, "mouse has automation property")


    ; test mouse inside windows class
    Run % "mspaint.exe " . A_ScriptDir . "\green.png"
    win := windows.waitOne({process: "mspaint.exe"})
    Yunit.assert(win != 0, "mspaint found")
    mouse.MoveTo(0, 0)
    pos := mouse.get()
    Yunit.assert(pos.x == 0, "Mouse to origin x")
    Yunit.assert(pos.y == 0, "Mouse to origin y")

    win.move(100, 100)
    win.resize(640, 480)

    region := win.getRegion()
    Yunit.assert(region.origin.automation != 0, "region.origin.automation")
    Yunit.assert(region.origin.x == 100, "Window region.x")
    Yunit.assert(region.origin.y == 100, "Window region.y")
    Yunit.assert(region.rect.automation != 0, "region.rect.automation")
    Yunit.assert(region.rect.w == 640, "Window rect.w")
    Yunit.assert(region.rect.h == 480, "Window rect.h")

    pos := region.getCenter()
    Yunit.assert(pos.x == 420, "Region center x")
    Yunit.assert(pos.y == 340, "Region center y")

    region.click()

    pos := mouse.get()
    Yunit.assert(pos.x == 420, "Region center x")
    Yunit.assert(pos.y == 340, "Region center y")

    win.close(0)
    popup := windows.waitOne({process: "mspaint.exe", classNN: "#32770"})
    popup.click(200, 130)

    sleep 100
    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win.isAlive() == false, "mspaint not Alive")

    region := win.getRegion()
    Yunit.assert(region.origin.automation != 0, "region.origin.automation")
    Yunit.assert(region.origin.x == 0, "closed window region.x")
    Yunit.assert(region.origin.y == 0, "closed window region.y")
    Yunit.assert(region.rect.automation != 0, "region.rect.automation")
    Yunit.assert(region.rect.w == 0, "closed window rect.w")
    Yunit.assert(region.rect.h == 0, "closed window rect.h")
  }

  Test_Automation_Region2() {
    local
    global RDA_Automation, Yunit
    automation := new RDA_Automation()
    region := automation.region(0, 0, 50, 50)

    Yunit.assert(region.toString() == "RDA_ScreenRegion{x: 0, y: 0, w: 50, h: 50}")
    Yunit.assert(region.getCenter().toString() == "RDA_ScreenPosition{x: 25, y: 25}")
    Yunit.assert(region.getTopLeft().toString() == "RDA_ScreenPosition{x: 0, y: 0}")
    Yunit.assert(region.getTopRight().toString() == "RDA_ScreenPosition{x: 50, y: 0}")
    Yunit.assert(region.getBottomLeft().toString() == "RDA_ScreenPosition{x: 0, y: 50}")
    Yunit.assert(region.getBottomRight().toString() == "RDA_ScreenPosition{x: 50, y: 50}")
  }


  End() {
  }
}
