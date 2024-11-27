class Test_RDA_Mouse {
  Begin() {
  }

  Test_4_Automation_WindowsMouse2() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    mouse := automation.mouse()

    mouse.moveTo(0, 0)
    sleep 250

    position := mouse.get()
    Yunit.assert(position.x == 0, "check mouse x at origin")
    Yunit.assert(position.y == 0, "check mouse y at origin")

    loop 5 {
      mouse.move(50, 25)
      sleep 250

      position := mouse.get()
      Yunit.assert(position.x == A_index * 50, A_index . " check mouse x at origin")
      Yunit.assert(position.y == A_index * 25, A_index . " check mouse y at origin")
    }
  }

  Test_4_Automation_WindowsMouse() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    windows := automation.windows()
    mouse := automation.mouse()


    ; test mouse inside windows class
    Run % "mspaint.exe " . A_ScriptDir . "\green.png"
    win := windows.waitOne({process: "mspaint.exe"})
    Yunit.assert(win != 0, "mspaint found")
    sleep 1000

    position := mouse.get()

    win.click(200, 200)
    win.close(0)
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

    ; test mouse itself
    position := mouse.get()
    mouse.move(25, 25)
    position2 := mouse.get()
    Yunit.assert(position.x + 25 == position2.x, "Mouse moved 25 on x")
    Yunit.assert(position.y + 25 == position2.y, "Mouse moved 25 on y")

    mouse.moveTo(101, 202)
    position := mouse.get()
    Yunit.assert(position.x == 101, "Mouse moved to 101 on x")
    Yunit.assert(position.y == 202, "Mouse moved to 202 on y")
  }


  End() {
  }
}
