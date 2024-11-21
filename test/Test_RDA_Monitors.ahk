#SingleInstance


class Test_RDA_Monitors {
  Begin() {
  }

  Test_Monitors() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    Yunit.assert(RDA_Automation.TIMEOUT != 0, "TIMEOUT set")
    Yunit.assert(RDA_Automation.DELAY != 0, "DELAY set")

    automation := new RDA_Automation()
    windows := automation.windows()
    monitors := automation.monitors()

    Yunit.assert(monitors.count() > 0, "has monitors!")

    monsInfo := monitors.get()

    Yunit.assert(monsInfo[1].display.x == 0, "first monitor x=0")
    Yunit.assert(monsInfo[1].display.y == 0, "first monitor y=0")

    Yunit.assert(monsInfo[1].display.w > 0, "first monitor has width")
    Yunit.assert(monsInfo[1].display.h > 0, "first monitor has height")
    Yunit.assert(StrLen(monsInfo[1].name) > 0, "first monitor has height")

    win := windows.get()[1]
    monitor := monitors.fromWindow(win.hwnd)
    Yunit.assert(StrLen(monitor.name) > 0, "first monitor has height")
    ; getter
    Yunit.assert(StrLen(win.monitor.name) > 0, "first monitor has height")
  }

  End() {
  }
}
