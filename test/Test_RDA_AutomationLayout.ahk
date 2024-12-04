class Test_RDA_AutomationLayout {
  Begin() {
  }


  Test_RDA_AutomationLayout() {
    local
    global RDA_Automation, Yunit, RDA_Layout

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("interactive", 500)
    windows := automation.windows()
    try {
      win := windows.findOne({process: "mspaint.exe"})
    } catch e {
      Run mspaint.exe
      win := windows.waitOne({process: "mspaint.exe"})
    }
    win.activate()

    winElement := win.asUIAElement()
    RDA_Log_Debug(winElement.dumpXML())
    layout := new RDA_Layout(win)

    layout.fromJsonFile(A_ScriptDir . "\paint.json")
    Yunit.assert(layout.elements.length() > 0, "there are elements parsed")

    ; everyone has a name/type/region
    loop % layout.elements.length() {
      el := layout.elements[A_Index]
      Yunit.assert(StrLen(el.name), "item[" . A_Index . "] has name")
      Yunit.assert(StrLen(el.type), "item[" . A_Index . "] has type")
      Yunit.assert(el.region != 0, "item[" . A_Index . "] has region")
    }

    layout.element("Type").click()
    ; there is no way to know if is "selected/pressed"
    ; Yunit.assert(winElement.findOne("//Button[@name=""Text""]") ??? , "Pressed?")
    layout.win.click(20, 165)

    layout.element("Font").selectByValue("Arial")
    Yunit.assert(winElement.findOne("//ComboBox[@name=""Font family""]").getValue() == "Arial", "Arial font set")
    ; check value is set

    layout.win.click(20, 165)
    layout.win.type("some arial text!")

    ; click outside to set the text
    layout.win.click(20, 200)

    ; TODO more tests!

    win.close(0)
    popup := win.getChild({classNN: "#32770"})
    popup.sendKeys("n")

    Yunit.assert(!popup.isAlive(), "no popup")
    Yunit.assert(!win.isAlive(), "no paint")
  }

  End() {
  }
}
