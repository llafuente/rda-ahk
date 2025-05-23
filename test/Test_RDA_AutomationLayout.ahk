class Test_RDA_AutomationLayout {
  Begin() {
  }


  Test_RDA_AutomationLayout() {
    local
    global RDA_Automation, Yunit, RDA_Layout

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("interactive", 500, 100)
    windows := automation.windows()
    mouse := automation.mouse()
    try {
      win := windows.findOne({process: "mspaint.exe"})
    } catch e {
      Run mspaint.exe
      win := windows.waitOne({process: "mspaint.exe"})
    }
    win.activate()
    win.move(50,50)
    win.resize(1024, 768)

    winElement := win.asUIAElement()
    RDA_Log_Debug(winElement.dumpXML())
    layout := new RDA_Layout(win)

    layout.fromJsonFile(A_ScriptDir . "\paint.json")
    Yunit.assert(layout.elements.length() > 0, "there are elements parsed")

    layout.element("Header").updateImage()

    layout.waitAppear()

    ; everyone has a name/type/region
    loop % layout.elements.length() {
      el := layout.elements[A_Index]
      Yunit.assert(StrLen(el.name), "item[" . A_Index . "] has name")
      Yunit.assert(StrLen(el.type), "item[" . A_Index . "] has type")
      Yunit.assert(el.region != 0, "item[" . A_Index . "] has region")
    }

    layout.element("Bucket").click()
    mouse.moveTo(0, 0)
    layout.element("Bucket").updateImage()
    Yunit.assert(layout.element("Bucket").waitEnabled(), "clicked and found")

    layout.element("Type").highlight(250).click()
    ; there is no way to know if is "selected/pressed"
    ; Yunit.assert(winElement.findOne("//Button[@name=""Text""]") ??? , "Pressed?")
    layout.win.mouseMoveTo(20, 165).click(20, 165)

/*
    ; flaky test, first letter trigger change on input

    fontFamily := winElement.findOne("//ComboBox[@name=""Font family""]")
    ;testFont := "Arial"
    ;testFont := "{LShift down}{vk41}{LShift up}rial"
    testFont := "arial"
    if (fontFamily.getValue() == "Arial") {
      testFont := "calibri"
    }

    layout.element("Font").selectByValue(testFont)
    Yunit.assert(format("{:L}", fontFamily.getValue()) == testFont, testFont . " font set")
    ; check value is set
*/

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
