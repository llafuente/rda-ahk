#SingleInstance


class Test_RDA_VirtualDesktops {
  Begin() {
  }

  Test_VirtualDektops() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    Yunit.assert(RDA_Automation.TIMEOUT != 0, "TIMEOUT set")
    Yunit.assert(RDA_Automation.DELAY != 0, "DELAY set")

    automation := new RDA_Automation()
    windows := automation.windows()
    vdesk := automation.virtualDesktops()

    Test_Kill_Processes(windows, {process: "NOTEPAD.exe", classNN: "Notepad"})
    Test_Kill_Processes(windows, {process: "mspaint.exe", "classNN": "MSPaintApp"})

    Run notepad.exe
    Run mspaint.exe

    notepad := windows.waitOne({process: "notepad.exe", classNN: "Notepad"}, true)
    paint := windows.waitOne({process: "mspaint.exe", "classNN": "MSPaintApp"}, true)

    notepad.move(75, 75).resize(1024, 768)
    paint.move(50, 50).resize(1024, 768)

    RDA_Log_Debug(notepad.toString())
    RDA_Log_Debug(paint.toString())

    Yunit.assert(vdesk.isWindowOnCurrent(notepad) == true, "1.A. notepad in current vdesk")
    Yunit.assert(notepad.isOnCurrentVirtualDesktop() == true, "1.B. notepad in current vdesk")
    Yunit.assert(vdesk.isWindowOnCurrent(paint.hwnd) == true, "2.A. paint in current vdesk")
    Yunit.assert(paint.isOnCurrentVirtualDesktop() == true, "2.B. paint in current vdesk")

    Yunit.assert(vdesk.count() > 1, "The test requires at least 2 virtual desktops!")

    desktops := vdesk.get()
    current := vdesk.current()

    RDA_Log_Debug(desktops[1].toString())
    RDA_Log_Debug(desktops[2].toString())
    RDA_Log_Debug(current.toString())

    Yunit.assert(desktops.length() > 1, "at least two virtual desktops again!")
    Yunit.assert(current.index == 1)

    Yunit.assert(vdesk.isWindowOnCurrent(paint.hwnd) == true, "paint is in the current vdesk")
    vdesk.switchTo(desktops[2])
    Yunit.assert(vdesk.isWindowOnCurrent(paint.hwnd) == false, "switched -> paint in current vdesk")
    Yunit.assert(paint.getSize().toString() == "RDA_Rectangle{w: 1024, h: 768}", "paint size")

    sleep 500

    vdesk.switchTo(desktops[1])
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == true, "switched2 -> paint in current vdesk")
    Yunit.assert(paint.getSize().toString() == "RDA_Rectangle{w: 1024, h: 768}", "paint size")
    sleep 500

    vdesk.MoveTo(notepad.hwnd, desktops[2])
    Yunit.assert(vdesk.IsWindowOnCurrent(notepad.hwnd) == false, "moved -> notepad in other vdesk")
    vdesk.MoveTo(paint.hwnd, desktops[2])
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == false, "moved -> paint in other vdesk")

    Yunit.assert(paint.getSize().toString() == "RDA_Rectangle{w: 1024, h: 768}", "paint at 2 size")
    Yunit.assert(paint.getPosition().toString() == "RDA_ScreenPosition{x: 50, y: 50}", "paint at 2 position")

    paint.move(100, 100)
    Yunit.assert(paint.getPosition().toString() == "RDA_ScreenPosition{x: 100, y: 100}", "paint at 2 after move position")

    desktop := vdesk.fromWindow(notepad.hwnd)
    Yunit.assert(desktop.index == 2, "notepad in vdesk 2")
    desktop := vdesk.fromWindow(paint.hwnd)
    Yunit.assert(desktop.index == 2, "paint in vdesk 2")
    vdesk.MoveTo(paint.hwnd, desktops[1])
    desktop := vdesk.fromWindow(paint.hwnd)
    Yunit.assert(desktop.index == 1, "moved -> paint in vdesk 1")

    vdesk.MoveTo(paint.hwnd, desktops[1])
    Yunit.assert(paint.getPosition().toString() == "RDA_ScreenPosition{x: 100, y: 100}", "paint at 1 position")

    notepad.close()
    paint.close()
  }

  End() {
  }
}
