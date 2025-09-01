class Test_RDA_Mouse {
  Begin() {
  }

  Test_Mouse() {
    local
    global RDA_Automation, Yunit, RDA_ScreenPosition

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    mouse := automation.mouse()

    mouse.moveTo(0, 0)
    sleep 250

    mouse.expectPosition2(0, 0, "check mouse x at origin")

    loop 5 {
      mouse.move(50, 25)
      sleep 250

      mouse.expectPosition2(A_index * 50, A_index * 25, " check mouse position[" . A_index . "]")
    }

    ; test mouse itself
    position := mouse.get()
    mouse.move(25, 25)
    mouse.expectPosition2(position.x + 25, position.y + 25, "Mouse moved 25 on x/y")

    mouse.moveTo(101, 202)
    position := mouse.get()
    mouse.expectPosition(new RDA_ScreenPosition(automation, 101, 202), "Mouse moved to (101,202)")
  }

  Test_Window_Mouse() {
    local
    global RDA_Automation, Yunit, TestOpenApp

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    mouse := automation.mouse()


    ; test mouse inside windows class
    Run % "mspaint.exe " . A_ScriptDir . "\green.png"
    win := windows.waitOne({process: "mspaint.exe"})
    win.closeOnDestruction()

    Yunit.assert(win != 0, "mspaint found")
    sleep 1000

    position := mouse.get()

    ; modify document to trigger popup
    win.resize(1024,768)
    win.click(200, 300)
    win.close(0)

    ;win.sendKeys("{CtrlDown}w{CtrlUp}")

    ; save changes ?
    popup := windows.waitOne({process: "mspaint.exe", classNN: "#32770"})
    popup.mouseMoveTo(200, 110)
    popup.sendKeys("n")

    sleep 1000
    Yunit.assert(popup.isAlive() == false, "popup closed")
    Yunit.assert(win.isAlive() == false, "app closed")


    position2 := mouse.get()

    Yunit.assert(position.x != position2.x, "Mouse moved on x")
    Yunit.assert(position.y != position2.y, "Mouse moved on y")
  }


  Test_Mouse_Cursor() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    mouse := automation.mouse()

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})
    win.closeOnDestruction()
    win.move(50,50)
    win.resize(1024,768)

    win.pixel(10,10).mouseMove()
    mouse.waitCursor("SizeWE")
    mouse.expectCursor(["SizeWE"], "unexpected cursor at left")

    win.pixel(50,60).mouseMove()
    mouse.expectCursor(["Arrow", "AppStarting"], "unexpected cursor at menu")
    mouse.waitCursor("Arrow")

    ;Yunit.assert(mouse.getCursor() == , "AppStarting")
    ;Yunit.assert(RDA_Array_IndexOf(["Arrow", "AppStarting"], mouse.getCursor()) > 0, "Arrow or AppStarting")

    win.pixel(100,100).mouseMove()
    Yunit.assert(mouse.getCursor() == "IBeam", "IBeam")

    win.pixel(1019,250).mouseMove()
    Yunit.assert(mouse.isCursor("SizeWE"), "SizeWE")

    win.pixel(200,760).mouseMove()
    mouse.expectCursor("SizeNS", "Expected mouse cursor: SizeNS")
  }

  End() {
  }
}
