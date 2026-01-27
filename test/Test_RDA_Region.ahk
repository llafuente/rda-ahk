class Test_RDA_Region {
  Begin() {
  }

  Test_RDA_Region_Math() {
    local
    global Yunit, RDA_Automation, RDA_ScreenRegion, RDA_WindowRegion


    automation := new RDA_Automation()

    a := RDA_ScreenRegion.fromPoints(automation, 0, 0, 50, 50)
    b := RDA_ScreenRegion.fromPoints(automation, 25, 25, 50, 50)

    c := RDA_ScreenRegion.fromPoints(automation, 75, 0, 50, 50)
    d := RDA_ScreenRegion.fromPoints(automation, 75, -75, 50, 50)
    e := RDA_ScreenRegion.fromPoints(automation, -75, 0, 50, 50)
    f := RDA_ScreenRegion.fromPoints(automation, -75, -75, 50, 50)

    Yunit.assert(a.intersection(b).toString() == "RDA_ScreenRegion{x: 25, y: 25, w: 25, h: 25}", "cehck a∩b ok")


    h := RDA_ScreenRegion.fromPoints(automation, 5, 5, 5, 5)

    lastException := 0
    try {
      a.intersection(c).toString()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Do not intercept", "a∩c Do not intercept")

    lastException := 0
    try {
      a.intersection(d).toString()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Do not intercept", "a∩d Do not intercept")

    lastException := 0
    try {
      a.intersection(e).toString()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Do not intercept", "a∩e Do not intercept")

    lastException := 0
    try {
      a.intersection(f).toString()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Do not intercept", "a∩f Do not intercept")


    lastException := 0
    try {
      b.intersection(h).toString()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Do not intercept", "a∩h Do not intercept")
  }

  Test_RDA_Region_Window_ScreenRegion() {
    local
    global RDA_Automation, Yunit, TestOpenApp, RDA_WindowRegion, RDA_ScreenRegion

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    Yunit.assert(windows.automation != 0, "windows has automation property")
    mouse := automation.mouse()
    Yunit.assert(mouse.automation != 0, "mouse has automation property")


    ; test mouse inside windows class
    app := new TestOpenApp("mspaint.exe " . A_ScriptDir . "\green.png", {process: "mspaint.exe"})
    win := app.win
    Yunit.assert(win != 0, "mspaint found")
    mouse.MoveTo(0, 0)
    pos := mouse.get()
    Yunit.assert(pos.x == 0, "Mouse to origin x")
    Yunit.assert(pos.y == 0, "Mouse to origin y")

    win.move(100, 100)
    win.resize(1024, 768)

    region := win.getRegion()
    ;RDA_Assert(RDA_instaceOf(region, RDA_WindowRegion), "expected region to be instance of RDA_WindowRegion")
    RDA_Assert(RDA_instaceOf(region, RDA_ScreenRegion), "expected region to be instance of RDA_ScreenRegion")

    RDA_Log_Debug(A_ThisFunc . " region = " . region.toString())

    Yunit.assert(region.origin.automation != 0, "region.origin.automation")
    Yunit.assert(region.origin.x == 100, "Window region.x")
    Yunit.assert(region.origin.y == 100, "Window region.y")
    Yunit.assert(region.rect.automation != 0, "region.rect.automation")
    Yunit.assert(region.rect.w == 1024, "Window rect.w")
    Yunit.assert(region.rect.h == 768, "Window rect.h")

    region2 := region.clone()
    Yunit.assert(region2.origin.x == 100, "cloned region.x")
    Yunit.assert(region2.origin.y == 100, "cloned region.y")
    Yunit.assert(region2.rect.w == 1024, "cloned rect.w")
    Yunit.assert(region2.rect.h == 768, "cloned rect.h")
    region2.origin.x := 101
    Yunit.assert(region2.origin.x == 101, "cloned changed")
    Yunit.assert(region.origin.x == 100, "original region not changed")
    region2.highlight(250)

    region2.expandOut(10)
    Yunit.assert(region2.origin.x == 101 - 10, "cloned and expanded region.x")
    Yunit.assert(region2.origin.y == 100 - 10, "cloned and expanded region.y")
    Yunit.assert(region2.rect.w == 1024 + 20, "cloned and expanded rect.w")
    Yunit.assert(region2.rect.h == 768 + 20, "cloned and expanded rect.h")
    region2.highlight(250)

    ; check center
    pos := region.getCenter()
    Yunit.assert(pos.x == 612, "Region center x")
    Yunit.assert(pos.y == 484, "Region center y")

    region.highlight(250)
    region.click()

    ; final mouse position should be the center!
    pos := mouse.get()
    Yunit.assert(pos.x == 612, "Region center x")
    Yunit.assert(pos.y == 484, "Region center y")

    win.close(0)
; test code to find the dialog window
;     wins := windows.find({process: "mspaint.exe"})
;     loop % wins.length() {
;       RDA_Log_Debug(wins[A_Index].toString())
;     }

    ; win10
    ; popup := windows.waitOne({process: "mspaint.exe", classNN: "#32770"})
    ; popup.click(200, 130)
    ; w11
    popup := windows.waitOne({process: "mspaint.exe", classNN: "XAMLModalWindow"})
    popup.sendKeys("n")

    sleep 100
    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win.isAlive() == false, "mspaint not Alive")

    ; check closed window region
    region := win.getRegion()
    Yunit.assert(region.origin.automation != 0, "region.origin.automation")
    Yunit.assert(region.origin.x == 0, "closed window region.x")
    Yunit.assert(region.origin.y == 0, "closed window region.y")
    Yunit.assert(region.rect.automation != 0, "region.rect.automation")
    Yunit.assert(region.rect.w == 0, "closed window rect.w")
    Yunit.assert(region.rect.h == 0, "closed window rect.h")
  }


  Test_RDA_Region_Window_WindowRegion() {
    local
    global RDA_Automation, Yunit, TestOpenApp, RDA_WindowRegion, RDA_ScreenRegion, RDA_WindowPosition, RDA_ScreenPosition

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    Yunit.assert(windows.automation != 0, "windows has automation property")
    mouse := automation.mouse()
    Yunit.assert(mouse.automation != 0, "mouse has automation property")


    ; test mouse inside windows class
    app := new TestOpenApp("mspaint.exe " . A_ScriptDir . "\green.png", {process: "mspaint.exe"})
    win := app.win

    win.move(100, 100)
    win.resize(1024, 768)

    wregion := win.getWindowRegion()
    RDA_Assert(RDA_instaceOf(wregion, RDA_WindowRegion), "expected region to be instance of RDA_WindowRegion")

    sregion := wregion.toScreen()
    RDA_Assert(RDA_instaceOf(sregion, RDA_ScreenRegion), "expected region to be instance of RDA_ScreenRegion")

    RDA_Log_Debug(A_ThisFunc . " wregion = " . wregion.toString())
    RDA_Log_Debug(A_ThisFunc . " sregion = " . sregion.toString())

    Yunit.assert(wregion.origin.x == 0, "Window region.x")
    Yunit.assert(wregion.origin.y == 0, "Window region.y")
    Yunit.assert(wregion.rect.w == 1024, "Window rect.w")
    Yunit.assert(wregion.rect.h == 768, "Window rect.h")

    Yunit.assert(sregion.origin.x == 100, "Window region.x")
    Yunit.assert(sregion.origin.y == 100, "Window region.y")
    Yunit.assert(sregion.rect.w == 1024, "Window rect.w")
    Yunit.assert(sregion.rect.h == 768, "Window rect.h")

    wpoint := wregion.getCenter()
    spoint := sregion.getCenter()

    RDA_Assert(RDA_instaceOf(wpoint, RDA_WindowPosition), "expected wpoint to be instance of RDA_WindowRegion")
    RDA_Assert(RDA_instaceOf(spoint, RDA_ScreenPosition), "expected spoint to be instance of RDA_ScreenRegion")

    spoint2 := wpoint.toScreen()
    RDA_Assert(RDA_instaceOf(spoint2, RDA_ScreenPosition), "expected spoint2 to be instance of RDA_ScreenRegion")

    Yunit.assert(spoint2.x == spoint.x, "Window and screen center x are the same!")
    Yunit.assert(spoint2.y == spoint.y, "Window and screen center y are the same!")

    wpoint.click()

    win.move(125, 125)
    wregion := win.getWindowRegion()
    wpoint := wregion.getCenter()
    spoint3 := wpoint.toScreen()

    Yunit.assert(spoint2.x + 25 == spoint3.x, "After move, center also move! x")
    Yunit.assert(spoint2.y + 25 == spoint3.y, "After move, center also move! y")

    wpoint.click()

    win.close(0)
    popup := windows.waitOne({process: "mspaint.exe", classNN: "XAMLModalWindow"})
    popup.sendKeys("n")

    sleep 100
    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win.isAlive() == false, "mspaint not Alive")
  }

  Test_RDA_Region_Class() {
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

  Test_RDA_Region_Interface() {
    local
    global Yunit, RDA_Automation, RDA_ScreenRegion, RDA_WindowRegion
    ; check WindowRegion and ScreenRegion has the same interface

    automation := new RDA_Automation()
    windows := automation.windows()
    Yunit.assert(windows.automation != 0, "windows has automation property")

    ; win := windows.get()[1]
    screenMethods := []
    for k,v in RDA_ScreenRegion {
      screenMethods.push(k)
    }
    windowMethods := []
    for k,v in RDA_WindowRegion {
      windowMethods.push(k)
    }
    diff := ArrayDiff(screenMethods, windowMethods)
    RDA_Log_Debug(A_ThisFunc .  " Missing some methods = " . RDA_JSON_Stringify(diff, 0, 2))
    Yunit.assert(diff.length() == 3, "Missing some methods")
  }


  End() {
  }
}
