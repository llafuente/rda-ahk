class Test_RDA_Keyboard {
  Begin() {
  }
/*
  Test_6_Automation_Keyboard() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})

    keyboard.sendKeys("hello ")
    keyboard.sendPassword("world{ENTER}")

    wins := windows.get()
    Run notepad.exe
    win2 := windows.waitOneNew({process: "notepad.exe"}, wins)

    win.SendKeys("123-")
    win2.SendKeys("456-")
    win.sendPassword("789-")
    win2.sendPassword("012-")

    win.close(0)
    sleep 1000

    popup := win.getChild({classNN: "#32770"})
    popup.sendKeys("n")

    sleep 1000

    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win.isAlive() == false, "notepad not Alive")

    win2.close(0)
    sleep 1000

    popup := win2.getChild({classNN: "#32770"})
    popup.sendKeys("n")

    sleep 1000

    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win2.isAlive() == false, "notepad not Alive")
  }
*/

  Test_7_Automation_KeyboardBackground() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})

    win.move(50, 50)
    win.resize(640, 480)
    win.minimize()

    lastException := 0
    try {
      keyboard.sendKeys("hello ")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "hwnd is required in background input mode", "throws using keyboard directly")

    win.sendPassword("world{ENTER}")
    win.restore()

    sleep 500
    region := win.getRegion()
    Yunit.assert(region.rect.w == 640, "notepad(resize) size on x")
    Yunit.assert(region.rect.h == 480, "notepad(resize) size on y")
    Yunit.assert(win.isMaximized() == false, "1 notepad maximized?")

    win.maximize()
    sleep 500
    region := win.getRegion()
    Yunit.assert(region.rect.w > 640, "notepad(maximize) size on x")
    Yunit.assert(region.rect.h > 480, "notepad(maximize) size on y")
    Yunit.assert(win.isMaximized() == true, "2 notepad maximized?")
    sleep 500

    win.restore()
    sleep 500
    region := win.getRegion()
    Yunit.assert(region.rect.w == 640, "notepad(restored) size on x")
    Yunit.assert(region.rect.h == 480, "notepad(restored) size on y")
    Yunit.assert(win.isMaximized() == false, "3 notepad maximized?")

    win.close(0)
    popup := win.getChild({classNN: "#32770"})
    popup.sendKeys("n")

    sleep 1000

    Yunit.assert(popup.isAlive() == false, "popup not Alive")
    Yunit.assert(win.isAlive() == false, "notepad not Alive")
  }


  End() {
  }
}
