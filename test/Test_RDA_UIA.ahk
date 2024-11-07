class Test_RDA_UIA {
  Begin() {
  }


  Test_14_Automation_UIA() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation()
    ;automation.setActionDelay(50)
    windows := automation.windows()
    mouse := automation.mouse()
    wins := windows.get()
    Yunit.assert(wins.Length() > 0, "Return some windows")

    Run notepad.exe
    win := windows.waitOne({process: "notepad.exe"})
    win.move(50, 50)
    win.resize(640, 480)

    ; Run calc.exe
    ; win := windows.waitOne({process: "Calculator.exe"})
    ; win := windows.waitOne({title: "Calculator"}, 5000)

    win.activate()
    uiaWin := win.asUIAElement()

    ; event handler tests
    ;handler := UIA_CreateEventHandler("StructureChangedEventHandler", "StructureChanged")
    ;automation._UIA().AddStructureChangedEventHandler(uiaWin.uiaHandle,,, handler)

    ;handler := UIA_CreateEventHandler("FocusEventHandler", "FocusChanged")
    ;automation._UIA().AddFocusChangedEventHandler(handler)

    ;uiaWin.onFocusChange("FocusEventHandler")

    ;handler := UIA_CreateEventHandler("NotificationEventHandler", "Notification")
    ;automation._UIA().AddNotificationEventHandler(uiaWin.uiaHandle,,, handler)


    lastException := 0
    try {
      uiaWin.setValue("xxx")
    } catch e {
      lastException := e
    }

    Yunit.assert(lastException.message == "ValuePattern not implemented", "Window do not implement ValuePattern")


    mouse.moveTo(50, 50)
    win.resize(640, 480)

    total := 26
    elements := uiaWin.getDescendants()
    Yunit.assert(elements.length() == total, "(getDescendants) There are 26 elements in the tree")

    RDA_Log_Debug(uiaWin.dumpXML())

    elements := uiaWin.find("//*")
    Yunit.assert(elements.length() == total, "(find)There are 26 elements in the tree")

    elements := uiaWin.find("//MenuItem")
    Yunit.assert(elements.length() == 6, "There are 6 MenuItem(s)")

    elements := uiaWin.find("//*[@Type != ""MenuItem""]")
    Yunit.assert(elements.length() == total - 6, "There are 26-6 not MenuItem(s)")

    fileMenuItem := uiaWin.findOne("//MenuItem[@Name=""File""]")
    Yunit.assert(fileMenuItem.getName() == "File", "First MenuItem is File")

    elements2 := uiaWin.find("//*[@Type = ""MenuItem"" and @Name=""File""]")
    Yunit.assert(elements2.length() == 1, "2. Single MenuItem@File")
    Yunit.assert(fileMenuItem.isSameElement(elements2[1]) == true, "MenuItem is File == MenuItem is File")


    ;fileMenuItem.click()
    fileMenuItem.osClick()

    controls := uiaWin.find("//MenuItem")
    Yunit.assert(controls.length() > 6, "Now there are more MenuItem after opening File")

    aux := uiaWin.getFocusedControl()
    Yunit.assert(aux.getName() == fileMenuItem.getName(), "File is the focused element")

    Yunit.assert(uiaWin.getName() == "Untitled - Notepad", "check window name")
    {
      element := uiaWin.findOne("/2")
      Yunit.assert(element.getName() == "Text Editor", "check /1 name")
      element.hover()
      position := mouse.get()
      Yunit.assert(position.move(-370, -300).getLength() < 2, "mouse center at Text Editor")
    }
    {
      element := uiaWin.findOne("/2/1")
      Yunit.assert(element.getName() == "Vertical", "check /1/1 name")
      element.hover()
      position := mouse.get()
      Yunit.assert(position.move(-673, -291).getLength() < 2, "mouse center at Text Editor")
    }
    {
      element := uiaWin.findOne("/2/2")
      Yunit.assert(element.getName() == "Horizontal", "check /1/1 name")
    }
    {
      element := uiaWin.findOne("/2/1/2")
      Yunit.assert(element.getName() == "Line down", "check /2/1/2 name")
    }
    {
      element := uiaWin.findOne("/2/1/1")
      Yunit.assert(element.getName() == "Line up", "check /2/1/1 name")
    }


    win.getRegion().highlight()
    {
      textarea := uiaWin.findOne("//*[@Type=""Document"" or @Type=""Edit""]")
      ;control.Highlight() ; Highlight the found element
      textarea.SetValue("Lorem ipsum")
      ;items := win.find("Type=MenuItem")
      ;loop % items.length() {
      ;  items[A_Index].Highlight()
      ;}

      Yunit.assert(textarea.getValue() == "Lorem ipsum", "written text")
    }


    uiaWin.findOne("//*[@Name=""File"" and @Type=""MenuItem""]").Click()
    uiaWin.waitOne("//*[@Name=""Page Setup..."" and @Type=""MenuItem""]").click()

    ; "Name='Page Setup' and @Type=Window"
    popupWin := win.waitChild({classNN: "#32770"})
    popup := popupWin.asUIAElement()

    RDA_Log_Debug(popup.dumpXML())

    ; click on the "Page size" -> "open"
    SizeComboBox := popup.findOne("//ComboBox[@Name=""Size:""]")
    SizeComboBox.findOne("//*[@Name=""Open"" and @Type=""Button""]").click()

    sizeSelection := popup.waitOne("//*[@Name=""Size:"" and @Type=""List""]")
    Yunit.assert(sizeSelection.canSelectMultiple() == false, "Size is single selection")
    ; We cannot test the element itself, we cannot assume it the one we want here
    Yunit.assert(sizeSelection.getSelectedItems().length() == 1, "One element is selected")

    ; click on a hidden item, the worst case scenario :P
    listItem := popup.waitOne("//ListItem[@Name=""12\"" x 18\""""]")
    Yunit.assert(listItem.isVisible() == false, "ListItem is not visible")
    listItem.click()

    ; check selection!
    Yunit.assert(sizeSelection.getSelectedItems()[1].getName() == "12"" x 18""", "Check selected size value")

    control := popup.findOne("//RadioButton[@Name=""Landscape""]")
    control.click()
    Yunit.assert(control.isSelected() == true, "Landscape is selected")

    popup.findOne("//Edit[@Name='Footer:']").SetValue("99")
    Yunit.assert(popup.findOne("//Edit[@Name='Footer:']").getValue() == "99")
    popup.findOne("//Edit[@Name='Header:']").SetValue("99")
    popup.findOne("//Edit[@Name='Bottom:']").SetValue("99")
    popup.findOne("//Edit[@Name='Top:']").SetValue("99")

    popup.findOne("//*[@Name='Cancel' and @Type='Button']").click()
    ; popup.sendKeys("{esc}")
    popupWin.waitClose()

    uiaWin.findOne("//MenuItem[@Name='Edit']").click()
    uiaWin.waitOne("//MenuItem[@Name='Replace...']").click()
    popupWin := win.waitChild({classNN: "#32770"})
    popup := popupWin.asUIAElement()

    RDA_Log_Debug(popup.dumpXML())

    checkbox := popup.findOne("//CheckBox[@Name = 'Wrap around']")
    checkbox.ensureChecked()
    Yunit.assert(checkbox.isChecked() == true, "ensureChecked 1")
    checkbox.ensureChecked()
    Yunit.assert(checkbox.isChecked() == true, "ensureChecked 2")
    checkbox.ensureUnchecked()
    Yunit.assert(checkbox.isChecked() == false, "ensureUnchecked 1")
    checkbox.toggle()
    Yunit.assert(checkbox.isChecked() == true, "toggle")
    checkbox.toggle()
    Yunit.assert(checkbox.isChecked() == false, "toggle")


    {
      checkbox := popup.findOne("//CheckBox[@Name = 'Match case']")
      checkbox.ensureChecked()
      Yunit.assert(checkbox.isChecked() == true, "ensureChecked 1")
    }

    {
      popup.findOne("//Edit[@Name = 'Find what:']").SetValue("ipsu")
      popup.findOne("//Button[@Name = 'Find Next']").click()
    }

    RDA_Log_Debug(popup.dumpXML())
    ; TODO test getSelectedText
    control := uiaWin.findOne("//Document[@Name=""Text Editor""]")
    control.Highlight() ; Highlight the found element
    RDA_Log_Debug(control.getSelectedText())
    Yunit.assert(control.getSelectedText() == "ipsu", "ipsu is selected!")

    {
      ; it takes some time to change the title, here we give plenty of time!
      Yunit.assert(uiaWin.getName() == "Untitled - Notepad", "check window name cached")
      Yunit.assert(uiaWin.getName(false) == "Untitled - Notepad", "check window name current")

      ; this is because UIA do not trigger changes in the window.
      win.sendKeys("{ENTER}")

      Yunit.assert(uiaWin.getName(false) == "*Untitled - Notepad", "check window name current 2")
    }


    ; win.close(0)
    uiaWin.findOne("//MenuItem[@Name='File']").click()
    uiaWin.waitOne("//MenuItem[@Name='Exit']").click()

    ; uiaWin.dumpTree()
    ; popup := win.getChild({classNN: "#32770"})
    ; popup.sendKeys("n")
    ;control := uiaWin.uiaWin.FindFirstByNameAndType("Don't Save", "Button")
    ; control := uiaWin.waitOne({name: "Don't Save": type: "Button"})
    control := uiaWin.waitOne("//Button[@Name=""Don't Save""]")
    control.click()

    win.waitClose()
    Yunit.assert(win.isClosed() == true, "notepad is closed")
    Yunit.assert(win.isAlive() == false, "notepad is alive")
  }

  End() {
  }
}