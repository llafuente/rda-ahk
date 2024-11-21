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

    Run notepad.exe
    Run mspaint.exe

    notepad := windows.waitOne({process: "notepad.exe", classNN: "Notepad"}, true)
    paint := windows.waitOne({process: "mspaint.exe", "classNN": "MSPaintApp"}, true)

    RDA_Log_Debug(notepad.toString())
    RDA_Log_Debug(paint.toString())

    Yunit.assert(vdesk.IsWindowOnCurrent(notepad.hwnd) == true, "1. notepad in current vdesk")
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == true, "1. paint in current vdesk")

    ;paint.activate()
    ;notepad.activate()

    Yunit.assert(vdesk.count() == 2, "two virtual desktops!")

    desktops := vdesk.get()
    current := vdesk.current()

    RDA_Log_Debug(desktops[1].toString())
    RDA_Log_Debug(desktops[2].toString())
    RDA_Log_Debug(current.toString())

    Yunit.assert(desktops.length() == 2, "two virtual desktops again!")
    Yunit.assert(current.index == 1)

    vdesk.switchTo(desktops[2])
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == false, "switched -> paint in not current vdesk")
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == false, "switched -> paint in current vdesk")
    sleep 500

    vdesk.switchTo(desktops[1])
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == true, "switched2 -> paint in not current vdesk")
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == true, "switched2 -> paint in current vdesk")
    sleep 500

    vdesk.MoveTo(notepad.hwnd, desktops[2])
    Yunit.assert(vdesk.IsWindowOnCurrent(notepad.hwnd) == false, "moved -> notepad in other vdesk")
    vdesk.MoveTo(paint.hwnd, desktops[2])
    Yunit.assert(vdesk.IsWindowOnCurrent(paint.hwnd) == false, "moved -> paint in other vdesk")

    desktop := vdesk.fromWindow(notepad.hwnd)
    Yunit.assert(desktop.index == 2, "notepad in vdesk 2")
    desktop := vdesk.fromWindow(paint.hwnd)
    Yunit.assert(desktop.index == 2, "paint in vdesk 2")
    vdesk.MoveTo(paint.hwnd, desktops[1])
    desktop := vdesk.fromWindow(paint.hwnd)
    Yunit.assert(desktop.index == 1, "moved -> paint in vdesk 1")

    notepad.close()
    paint.close()
  }

  End() {
  }
}
