class Test_RDA_Keyboard {
  Begin() {
  }
/*
  Test_Keyboard_VirtualKeys() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    RDA_Assert(keyboard.getKeyboardLayouts().length() > 0, "at least one keyboard")

    hkl_es := 67767306

    Yunit.assert(keyboard.letterToVirtualKey("a", hkl_es).toString() == "{vk41}", "a as vk")
    Yunit.assert(keyboard.letterToVirtualKey("A", hkl_es).toString() == "{LShift Down}{vk41}{LShift Up}", "A as vk")
    Yunit.assert(keyboard.letterToVirtualKey("(", hkl_es).toString() == "{LShift Down}{vk38}{LShift Up}", "( as vk")

    RDA_Assert(keyboard.textToSendKeys("hola", hkl_es) == "{vk48}{vk4f}{vk4c}{vk41}", "hola failed!")
    RDA_Assert(keyboard.textToSendKeys("hOla", hkl_es) == "{vk48}{LShift Down}{vk4f}{LShift Up}{vk4c}{vk41}", "hOla failed!")
    RDA_Assert(keyboard.textToSendKeys("hOLa", hkl_es) == "{vk48}{LShift Down}{vk4f}{vk4c}{LShift Up}{vk41}", "hOLa failed!")
    RDA_Assert(keyboard.textToSendKeys("hOLA", hkl_es) == "{vk48}{LShift Down}{vk4f}{vk4c}{vk41}{LShift Up}", "hOLa failed!")

    RDA_Assert(keyboard.textToSendKeys("\", hkl_es) == "{LControl Down}{LAlt Down}{vkdc}{LControl Up}{LAlt Up}", "\ failed!")
    RDA_Assert(keyboard.textToSendKeys("|", hkl_es) == "{LControl Down}{LAlt Down}{vk31}{LControl Up}{LAlt Up}", "| failed!")


    hkl_en := 67699721
    Yunit.assert(keyboard.letterToVirtualKey("(", hkl_en).toString() == "{LShift Down}{vk39}{LShift Up}", "( as vk english")
  }

  Test_Keyboard() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    keyboard := automation.keyboard()
    Yunit.assert(keyboard.automation != 0, "keyboard.automation not null")

    Run wordpad.exe
    win := windows.waitOne({process: "wordpad.exe"})

    keyboard.sendKeys("hello ")
    keyboard.sendPassword("world{ENTER}")
    previousWindows := windows.get()
    Run wordpad.exe
    win2 := windows.waitOneNew({process: "wordpad.exe"}, previousWindows)

    win.SendKeys("123-")
    win2.SendKeys("456-")
    win.sendPassword("789-")
    win2.sendPassword("012-")

    win.sendKeys("{CTRL Down}a{CTRL up}{CTRL Down}c{CTRL up}")
    RDA_Log_Debug(A_ThisFunc  " win clipboard = " . Clipboard)
    Yunit.assert(Clipboard == "hello world`r`n123-789-", "check clipboard win")

    win2.sendKeys("{CTRL Down}a{CTRL up}{CTRL Down}c{CTRL up}")
    RDA_Log_Debug(A_ThisFunc  " win2 clipboard = " . Clipboard)
    Yunit.assert(Clipboard == "456-012-", "check clipboard win")

    win.close(0)
    dialog := win.waitChild({"classNN": "#32770"})
    dialog.sendKeys("n")
    dialog.expectDead()
    win.expectDead()

    win2.close(0)
    dialog := win2.waitChild({"classNN": "#32770"})
    dialog.sendKeys("n")
    dialog.expectDead()
    win2.expectDead()
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

    ; win.defaultBackgroundControl := "ahk_parent"
    ; w11
    win.defaultBackgroundControl := "RichEditD2DPT1"
    win.sendKeys("hello world{ENTER}")

    Yunit.assert(win.isMinimized() == false, "notepad (1) minimized -> no")
    win.minimize()
    Yunit.assert(win.isMinimized() == true, "notepad (2) minimized -> yes")

    lastException := 0
    try {
      keyboard.sendKeys("xxx")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "hwnd is required in background input mode", "throws using keyboard directly")

    win.sendKeys("hello world{ENTER}")

    Yunit.assert(win.isMinimized() == true, "notepad (3) minimized -> yes")
    win.restore()
    Yunit.assert(win.isMinimized() == false, "notepad (4) minimized -> no")

    automation.setInputMode("interactive")
    win.sendKeys("{CTRL Down}e{CTRL up}{CTRL Down}c{CTRL up}")
    ;win.sendKeys("{CTRL Down}a{CTRL up}{CTRL Down}c{CTRL up}")
    RDA_Log_Debug(A_ThisFunc  " win clipboard = " . Clipboard)
    Yunit.assert(Clipboard == "hello world`r`nhello world`r`n", "check clipboard win")

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
    win.sendKeys("n")
    win.expectDead()

    Yunit.assert(win.isAlive() == false, "notepad not Alive")
  }
*/
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
    ; w11
    win.defaultBackgroundControl := "RichEditD2DPT1"

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

    ; notepad "background" 0,0 starts at Edit1 position
    ; win.mouseMoveTo(100, 100)
    ;sleep 250
    ;win.rightClick()
    ;sleep 1000
    ;win.rightClick(100, 100)

    text := "012345678901234567890123456789012345678901234567890123456789"
    expectedText := ""
    loop 10 {
      win.sendKeys(text . "{Enter}")
      expectedText .= text . "`r`n"
    }
    win.click(100, 100)
    ;win.sendKeys("{LShift DOWN}{LControl DOWN}{HOME}{LControl UP}{LShift UP}")
    ;win.sendKeys("{LControl DOWN}c{LControl UP}{LShift UP}")
    win.sendKeys("{LControl DOWN}{vk41}{LControl UP}")
    win.sendKeys("{LControl DOWN}{vk43}{LControl UP}")

    Yunit.assert(Clipboard == expectedText, "check clipboard")

    Clipboard := ""

    ; TODO CLOSE IT!!
    win.close(0)
    win.expectDead()

    Yunit.assert(win.isAlive() == false, "notepad is not alive")
  }

  End() {
  }
}
