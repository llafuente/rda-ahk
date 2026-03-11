class Test_RDA_UIA_w11 {
  Begin() {
  }

  __highlight(uiaWin, xpath, element_count) {
    elements := uiaWin.find(xpath)
    loop % elements.length() {
      elements[A_Index].highlight()
    }

    Yunit.assert(elements.Length() == element_count, "expected: " . element_count . " elements: " . xpath)
  }

  ; visual test
  Test_Automation_UIA_Regions() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    ; open blank
    ; does not work
    ; RegWrite, REG_DWORD, HKCU, Software\Microsoft\Notepad, NotepadStartupSessionType, 1

    automation := new RDA_Automation()
    automation.setActionDelay(500)
    windows := automation.windows()
    mouse := automation.mouse()
    wins := windows.get()
    Yunit.assert(wins.Length() > 0, "Return some windows")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})
    win.closeOnDestruction()
    win.move(50, 50)
    win.resize(640, 480)

    win.activate()
    uiaWin := win.asUIAElement()

    RDA_Log_Debug(uiaWin.dumpXML())

    this.__highlight(uiaWin, "//Button[starts-with(@name, ""M"")]", 3)
    this.__highlight(uiaWin, "//Button[ends-with(@name, "")"")]", 5)
    this.__highlight(uiaWin, "//Button[contains(@name, ""Ctrl"")]", 4)
  }

  End() {
  }
}
