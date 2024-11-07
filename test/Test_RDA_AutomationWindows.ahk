class Test_RDA_AutomationWindows {
  Begin() {
  }

  Test_2_Automation_Windows() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    wins := windows.get()
    Yunit.assert(wins.Length() > 0, "Return some windows")

    Run notepad.exe
    sleep 2000
    win := windows.findOne({process: "notepad.exe"})

    Yunit.assert(win != 0, "Window exist")
    Yunit.assert(win.process == "notepad.exe", "Found notepad!")

    win.close()
    Yunit.assert(win.isClosed() == true, "notepad is closed")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})

    Yunit.assert(win != 0, "Window exist")
    Yunit.assert(win.process == "notepad.exe", "Found notepad!")

    Yunit.assert(win.isClosed() == false, "notepad not closed")
    Yunit.assert(win.isAlive() == true, "notepad isAlive")
    win.move(45, 55)
    win.resize(640, 480)

    position := win.getPosition()
    Yunit.assert(position.x == 45, "notepad position on x")
    Yunit.assert(position.y == 55, "notepad position on y")

    size := win.getSize()
    Yunit.assert(size.w == 640, "notepad size on x")
    Yunit.assert(size.h == 480, "notepad size on y")

    region := win.getRegion()
    Yunit.assert(region.origin.x == 45, "notepad(region) position on x")
    Yunit.assert(region.origin.y == 55, "notepad(region) position on y")
    Yunit.assert(region.rect.w == 640, "notepad(region) size on x")
    Yunit.assert(region.rect.h == 480, "notepad(region) size on y")

    ; resize again, avoid "old state is a valid state"
    win.move(99, 101)
    position := win.getPosition()
    Yunit.assert(position.x == 99, "notepad(2) position on x")
    Yunit.assert(position.y == 101, "notepad(2) position on y")

    win.resize(641, 481)
    size := win.getSize()
    Yunit.assert(size.w == 641, "notepad(2) size on x")
    Yunit.assert(size.h == 481, "notepad(2) size on y")

    ; now there is two notepad, and waitOne shall fail
    Run notepad.exe
    sleep 2000 ; wait to give the process time to start
    lastException := 0
    try {
      windows.waitOne({process: "notepad.exe"}, false, 1000)
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Multiple windows found", "Multiple windows found error")

    win.close()

    Yunit.assert(win.isClosed() == true, "notepad is closed")
    Yunit.assert(win.isAlive() == false, "notepad is alive")

    win := windows.waitOne({process: "notepad.exe"}, wins)
    win.close()

    Yunit.assert(win.isClosed() == true, "notepad is closed")
    Yunit.assert(win.isAlive() == false, "notepad is alive")
  }

  Test_3_Automation_WindowsNew() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    ; mspaint multiple isntances
    wins := windows.get()
    Run mspaint.exe
    sleep 3000
    wins := windows.findNew({process: "mspaint.exe"}, wins)
    Yunit.assert(wins.length() == 1, "mspaint found")

    wins := windows.get()
    Run mspaint.exe
    sleep 3000
    mspaint := windows.findOneNew({process: "mspaint.exe"}, wins)
    Yunit.assert(mspaint != 0, "mspaint2 found")

    wins := windows.get()
    Run mspaint.exe
    mspaint := windows.waitOneNew({process: "mspaint.exe"}, wins)

    lastException := 0
    try {
      mspaint := windows.findOne({process: "mspaint.exe"}, wins)
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Multiple windows found", "Multiple windows found error")


    paints := windows.find({process: "mspaint.exe"}, wins)
    loop % paints.length() {
      paints[A_Index].move(50 * A_Index, 50 * A_Index)
      paints[A_Index].activate()
      Yunit.assert(paints[A_Index].isActivated() == true, "Check windows is activated")
      paints[A_Index].close()
    }

    paints := windows.find({process: "mspaint.exe"}, wins)
    Yunit.assert(paints.length() == 0, "All paints are closed")
  }

  End() {
  }
}
