class Test_RDA_Keyboard {
  Begin() {
  }

  Test_Keyboard() {
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


  Test_Keyboard_Background() {
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

  Test_Keyboard_Background_and_VirtualDesktop() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    automation.setActionDelay(500)
    windows := automation.windows()
    mouse := automation.mouse()
    vdesk := automation.virtualDesktops()

    try {
      win := windows.findOne({process: "notepad.exe"})
    } catch e {
      Run notepad.exe
      win := windows.waitOne({process: "notepad.exe"})
    }

    ; virtualDesktop mess! we can't get position, size, region
    ; win.move(50, 75)

    desktops := vdesk.get()
    Yunit.assert(desktops.length() > 1, "test require at least two virtual desktops!")

    win.moveToVirtualDesktop(desktops[1])
    ; move and resize do not work on "another" virtual desktop
    win.move(0, 0)
    win.resize(640, 480)

    region := win.getRegion()
    Yunit.assert(region.x == 0, "region.x of a window in current desktop")
    Yunit.assert(region.y == 0, "region.y of a window in current desktop")
    Yunit.assert(region.w > 0, "region.w of a window in current desktop")
    Yunit.assert(region.h > 0, "region.h of a window in current desktop")

    win.moveToVirtualDesktop(desktops[2])

    region := win.getRegion()
    Yunit.assert(region.x == 0, "region.x of a window in a virtual desk")
    Yunit.assert(region.y == 0, "region.y of a window in a virtual desk")
    Yunit.assert(region.w == 0, "region.w of a window in a virtual desk")
    Yunit.assert(region.h == 0, "region.h of a window in a virtual desk")


    automation.setInputMode("background")
/*
    ; notepad "background" 0,0 starts at Edit1 position
    ; win.mouseMoveTo(100, 100)
    ;sleep 250
    ;win.rightClick()
    sleep 1000
    ;win.rightClick(100, 100)
*/
    text := "012345678901234567890123456789012345678901234567890123456789"
    expectedText := ""
    loop 10 {
      win.sendKeys(text . "{Enter}")
      expectedText .= text . "`r`n"
    }
    win.click(100, 100)
    ;win.sendKeys("{LShift DOWN}{LControl DOWN}{HOME}{LControl UP}{LShift UP}")
    ;win.sendKeys("{LControl DOWN}c{LControl UP}{LShift UP}")
    win.sendKeys("{LControl DOWN}{vk41}{LControl UP}{LShift UP}")
    win.sendKeys("{LControl DOWN}{vk43}{LControl UP}{LShift UP}")

    Yunit.assert(Clipboard == expectedText, "check clipboard")

    Clipboard := ""

    ; TODO CLOSE IT!!
    win.close(0)
    popup := win.getChild({classNN: "#32770"}, true)
    popup.defaultBackgroundControl := ""
    popup.sendKeys("n")
    sleep 1000
    Yunit.assert(popup.isAlive() == false, "popup is not alive")
    Yunit.assert(win.isAlive() == false, "notepad is not alive")
  }


  End() {
  }
}
