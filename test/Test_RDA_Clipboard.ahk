class Test_RDA_Clipboard {
  Begin() {
  }
  Test_11_Automation_Clipboard() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")
    wincb := automation.clipboard()
    Yunit.assert(wincb.automation != 0, "clipboard.automation not null")

    wincb.set("hello")
    value := wincb.get()

    Yunit.assert(value == "hello", "clipboard set/get has the same value")

    wincb.clear()
    value := wincb.get()
    Yunit.assert(value == "", "clipboard is cleared")


    setClipboard := ObjBindMethod(wincb, "set", "hello")

    SetTimer % setClipboard, 1000
    value := wincb.wait(2000)
    Yunit.assert(value == "hello", "clipboard wait -> set has the same value")
    SetTimer % setClipboard, Off
  }

  End() {
  }
}
