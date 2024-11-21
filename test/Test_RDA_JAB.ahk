class Test_RDA_JAB {
  Begin() {
  }


  Test_16_Automation_JAB() {
    local
    global RDA_Automation, Yunit, RDA_AutomationJABElement, RDA_AutomationJAB, RDA_ElementTreeNode

    RDA_Log_Debug(A_ThisFunc)

    full_reload := true

    ; do not start/stop javaswitch
    if (!full_reload) {
      RDA_AutomationJAB.JABSWITCH_ENABLED := 10
    }

    automation := new RDA_Automation()
    ;automation.setActionDelay(50)
    windows := automation.windows()
    mouse := automation.mouse()
    wins := windows.get()
    Yunit.assert(wins.Length() > 0, "Return some windows")

    JAVA_PATH := "C:\Program Files (x86)\Java\jre1.8.0_171\bin\"
    if (A_PtrSize == 8) {
      JAVA_PATH := "C:\Program Files\Java\jre1.8.0_171\bin\"
    }
    automation.jab.init(JAVA_PATH)

    try {
      win := windows.waitOne({title: "SwingSet"}, false, 0)
    } catch e {
      Run %JAVA_PATH%java.exe -jar SwingSet2.jar, % A_ScriptDir
      win := windows.waitOne({title: "SwingSet"}, 5000)
    }
    win.activate()

    winElement := win.asJABElement()
    Yunit.assert(winElement, "Window element created")


    ; **************************************************************************
    winElement.findOne("//ToggleButton[@description=""JInternalFrame demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    themesList := winElement.find("//Menu[@Name=""Themes""]")
    Yunit.assert(themesList.length() == 1, "Single themes found")
    ;Yunit.assert(themesList[1].__Class == RDA_AutomationJABElement, "instance of RDA_AutomationJABElement")

    themes := winElement.findOne("//Menu[@Name=""Themes""]")
    emerald := winElement.findOne("//RadioButton[@Name=""Emerald""]")
    aqua := winElement.findOne("//RadioButton[@Name=""Aqua""]")
    ;Yunit.assert(themes.__Class == RDA_AutomationJABElement, "instance of RDA_AutomationJABElement 2")
    Yunit.assert(themes.getName() == "Themes", "check Themes name")
    Yunit.assert(emerald.getName() == "Emerald", "check Emerald name")
    Yunit.assert(aqua.getName() == "Aqua", "check Aqua name")

    themes.click()
    emerald.click()
    Yunit.assert(emerald.isChecked() == true, "emerald is checked")

    themes.click()
    aqua.click()
    Yunit.assert(aqua.isChecked() == true, "aqua is checked")

    resizable := winElement.findOne("//CheckBox[@Name=""Resizable""]")
    resizable.ensureUnchecked()
    resizable.ensureChecked()
    resizable.ensureUnchecked()

    ; **************************************************************************

    winElement.findOne("//ToggleButton[@Description=""JComboBox demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    hair := winElement.findOne("//ComboBox[@Name=""Hair:""]")
    Yunit.assert(hair.hasPattern("Selection"), "Hair combobox has SelectionPattern")
    Yunit.assert(hair.getSelectedItems().length() == 1, "Hair One is selected")
    Yunit.assert(hair.canSelectMultiple() == false, "Hair single selection")

    eyes := winElement.findOne("//ComboBox[@Name=""Eyes & Nose:""]")
    Yunit.assert(hair.hasPattern("Selection"), "Eyes combobox has SelectionPattern")
    Yunit.assert(hair.getSelectedItems().length() == 1, "Eyes One is selected")
    Yunit.assert(hair.canSelectMultiple() == false, "Eyes single selection")

    mouth := winElement.findOne("//ComboBox[@Name=""Mouth:""]")
    Yunit.assert(hair.hasPattern("Selection"), "Mouth combobox has SelectionPattern")
    Yunit.assert(hair.getSelectedItems().length() == 1, "Mouth One is selected")
    Yunit.assert(hair.canSelectMultiple() == false, "Mouth single selection")


    brent := hair.findOne("//Label[@name=""Brent""]")
    Yunit.assert(brent.hasPattern("SelectionItem"), "brent list>label has SelectionItem")
    hair.osClick()
    brent.select()
    win.sendKeys("{Enter}")

    brent := eyes.findOne("//Label[@name=""Brent""]")
    eyes.osClick()
    brent.select()
    win.sendKeys("{Enter}")

    brent := mouth.findOne("//Label[@name=""Brent""]")
    mouth.osClick()
    brent.select()
    win.sendKeys("{Enter}")

    selected := hair.getSelectedItems()
    Yunit.assert(selected.length() == 1, "hair [Brent] is selected length 1")
    Yunit.assert(selected[1].getName() == "Brent", "hair [Brent] is selected")
    selected := eyes.getSelectedItems()
    Yunit.assert(selected.length() == 1, "eyes [Brent] is selected length 1")
    Yunit.assert(selected[1].getName() == "Brent", "eyes [Brent] is selected")
    selected := mouth.getSelectedItems()
    Yunit.assert(selected.length() == 1, "mouth [Brent] is selected length 1")
    Yunit.assert(selected[1].getName() == "Brent", "mouth [Brent] is selected")


    georges := hair.findOne("//Label[@name=""Georges""]")
    Yunit.assert(georges.hasPattern("SelectionItem"), "Georges list>label has SelectionItem")
    hair.osClick()
    georges.select()
    win.sendKeys("{Enter}")

    georges := eyes.findOne("//Label[@name=""Georges""]")
    eyes.osClick()
    georges.select()
    win.sendKeys("{Enter}")

    georges := mouth.findOne("//Label[@name=""Georges""]")
    mouth.osClick()
    georges.select()
    win.sendKeys("{Enter}")

    selected := hair.getSelectedItems()
    Yunit.assert(selected.length() == 1, "hair [Georges] is selected length 1")
    Yunit.assert(selected[1].getName() == "Georges", "hair [Georges] is selected")
    selected := eyes.getSelectedItems()
    Yunit.assert(selected.length() == 1, "eyes [Georges] is selected length 1")
    Yunit.assert(selected[1].getName() == "Georges", "eyes [Georges] is selected")
    selected := mouth.getSelectedItems()
    Yunit.assert(selected.length() == 1, "mouth [Georges] is selected length 1")
    Yunit.assert(selected[1].getName() == "Georges", "mouth [Georges] is selected")


    ; test that change is registered without ui!
    presets := winElement.findOne("//ComboBox[@Name=""Presets:""]")
    presets.osClick()
    presets.findOne("//Label[@Name=""Howard, Scott, Hans""]").select()
    win.sendKeys("{Enter}")

    presets.osClick()
    presets.findOne("//Label[@Name=""Jeff, Larry, Philip""]").select()
    win.sendKeys("{Enter}")

    Yunit.assert(hair.getSelectedItems()[1].getName() == "Jeff", "hair [Jeff] is selected")
    Yunit.assert(eyes.getSelectedItems()[1].getName() == "Larry", "eyes [Larry] is selected")
    Yunit.assert(mouth.getSelectedItems()[1].getName() == "Philip", "mouth [Philip] is selected")

    ; this breaks the app :D
    ;brent.unselect()
    ;Yunit.assert(comboBox.getSelectedItems().length() == 0, "clear selection?")


    ; **************************************************************************
    winElement.findOne("//ToggleButton[@Description=""JFileChooser demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    ; this will hang the main thread while modal dialog is open
    ; access bridge explorer also hang
    ; winElement.findOne("//PushButton[@name=""Show Plain JFileChooser""]").click()
    ; use the os to click so we won't hang
    winElement.findOne("//PushButton[@name=""Show Plain JFileChooser""]").osClick()

    popup := win.waitChild({title: "Open"})
    ;uiaWin := popup.asUIAElement()
    ;RDA_Log_Debug(uiaWin.dumpXML())
    try {
      popupElement := popup.asJABElement()
      popupElement.findOne("//PushButton[@name=""Cancel""]").click()
    } catch e {
      popup.sendKeys("{esc}")
    }


    ; **************************************************************************
    winElement.findOne("//ToggleButton[@Description=""JList demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    list := winElement.findOne("//Label[@name=""YoYoWorks""]").getParent()
    Yunit.assert(list.getType() == "List", "fetch list by path")
    Yunit.assert(list.canSelectMultiple() == true, "multiple selection")
    list.clearSelectedItems()

    Yunit.assert(list.getSelectedItems().length() == 0, "selection cleared")

    list.findOne("//Label[@name=""TeraTelecom""]").select()
    list.findOne("//Label[@name=""YoYoWorks""]").select()
    list.findOne("//Label[@name=""MetaSystems""]").select()

    Yunit.assert(list.getSelectedItems().length() == 3, "3 selected")


    ; **************************************************************************
    winElement.findOne("//ToggleButton[@Description=""JSplitPane demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    textEl := winElement.findOne("//Text[@name=""Divider Size""]")
    RDA_Log_Debug(textEl.getActions())

    Yunit.assert(textEl.getValue() != "", "Divider Size has value")

    textEl.setValue("123")
    Yunit.assert(textEl.getValue() == "123", "Divider Size has 123 value")
    textEl.setValue("999")
    Yunit.assert(textEl.getValue() == "999", "Divider Size has 999 value")

    textEl :=winElement.findOne("//Text[@name=""First Component's Minimum Size""]")
    textEl.osClick()

    textEl :=winElement.findOne("//Text[@name=""Second Component's Minimum Size""]")
    textEl.focus()

    textEl2 := automation.jab.getFocusedElement(win.hwnd)
    Yunit.assert(textEl.isSameElement(textEl2), "text focus check")

    winElement.findOne("//RadioButton[@name=""Vertically Split""]").click()
    winElement.findOne("//RadioButton[@name=""Horizontally Split""]").click()
    winElement.findOne("//CheckBox[@name=""Continuous Layout""]").click()
    winElement.findOne("//CheckBox[@name=""One-Touch expandable""]").click()

    ; **************************************************************************
    winElement.findOne("//ToggleButton[@Description=""JSlider demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    panel := winElement.findOne("//Panel[@name=""Horizontal""]")

    sliderEl := panel.findOne("//Slider[@name=""Plain""]")
    Yunit.assert(sliderEl.hasPattern("Value"), "Slide implement ValuePattern")

    RDA_Log_Info(sliderEl.getPatterns())
    RDA_Log_Info(sliderEl.getActions())

    Yunit.assert(sliderEl.getValue() != "", "Slider has value")

    ; TODO REVIEW we cannot set value of slider!?


    ; **************************************************************************
    winElement.findOne("//ToggleButton[@Description=""JTree demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    ; winElement.findOne("//Label[@name=""Music""]").click()
    winElement.findOne("//Label[@name=""Classical""]").click()
    winElement.findOne("//Label[@name=""Beethoven""]").click()
    winElement.findOne("//Label[@name=""concertos""]").click()
    winElement.findOne("//Label[@name=""Jazz""]").click()
    winElement.findOne("//Label[@name=""Rock""]").click()
    winElement.findOne("//Label[@name=""Rock""]").osClick()
    win.sendKeys("{F2}")
    win.type("Rock And Roll Baby!")
    win.sendKeys("{Enter}")

    ; label is renamed, shall be fetch with the new name!
    winElement.findOne("//Label[@name=""Rock And Roll Baby!""]")


    winElement.findOne("//ToggleButton[@description=""JButton, JRadioButton, JToggleButton, JCheckbox demos""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    demo := winElement.findOne("//PageTab[@name=""Button Demo""]")
    demo.select()
    demo.findOne("//PageTab[@name=""Radio Buttons""]").select()


    panel := winElement.findOne("//Panel[@name=""Text Radio Buttons""]")
    RDA_Log_Debug(panel.dumpXML())
    panel.highlight()
    radioButton := panel.findOne("//RadioButton[@name=""Radio One ""]")
    radioButton.highlight()
    radioButton.ensureChecked()
    Yunit.assert(radioButton.isChecked(), "Text Radio One checked")

    radioButton := panel.findOne("//RadioButton[@name=""Radio Two""]")
    radioButton.ensureChecked()
    Yunit.assert(radioButton.isChecked(), "Text Radio Two checked")

    radioButton := panel.findOne("//RadioButton[@name=""Radio Three""]")
    radioButton.ensureChecked()
    Yunit.assert(radioButton.isChecked(), "Text Radio Three checked")


    panel := winElement.findOne("//Panel[@name=""Image Radio Buttons""]")
    radioButton1 := panel.findOne("//RadioButton[@name=""Radio One ""]")
    radioButton2 := panel.findOne("//RadioButton[@name=""Radio Two""]")
    radioButton3 := panel.findOne("//RadioButton[@name=""Radio Three""]")

    radioButton1.ensureChecked()
    Yunit.assert(radioButton1.isChecked(), "1. Text Radio One checked")
    Yunit.assert(!radioButton2.isChecked(), "1. Text Radio One checked")
    Yunit.assert(!radioButton3.isChecked(), "1. Text Radio One checked")

    radioButton2.ensureChecked()
    Yunit.assert(!radioButton1.isChecked(), "2. Text Radio Two checked")
    Yunit.assert(radioButton2.isChecked(), "2. Text Radio Two checked")
    Yunit.assert(!radioButton3.isChecked(), "2. Text Radio Two checked")

    radioButton3.ensureChecked()
    Yunit.assert(!radioButton1.isChecked(), "3. Text Radio Two checked")
    Yunit.assert(!radioButton2.isChecked(), "3. Text Radio Two checked")
    Yunit.assert(radioButton3.isChecked(), "3. Text Radio Two checked")

    demo.findOne("//PageTab[@name=""Check Boxes""]").select()
    panel := winElement.findOne("//Panel[@name=""Text CheckBoxes""]")
    checkBox1 := panel.findOne("//CheckBox[@name=""One ""]")
    checkBox1.ensureChecked()
    Yunit.assert(checkBox1.isChecked(), "Checkbox One checked")

    checkBox2 := panel.findOne("//CheckBox[@name=""Two""]")
    checkBox2.ensureChecked()
    Yunit.assert(checkBox2.isChecked(), "Checkbox Two checked")

    checkBox3 := panel.findOne("//CheckBox[@name=""Three""]")
    checkBox3.ensureChecked()
    Yunit.assert(checkBox3.isChecked(), "Checkbox Three checked")


    winElement.findOne("//ToggleButton[@description=""JScrollPane demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    winElement.findOne("//ToggleButton[@description=""JTable demo""]").click()
    RDA_Log_Debug(winElement.dumpXML())

    before := winElement.getDescendants(automation.limits).length()
    automation.limits.skipChildrenOfTypes.push("Table")
    after := winElement.getDescendants(automation.limits).length()

    Yunit.assert(before == 422, "Table - before 422")
    Yunit.assert(after == 146, "Table - after 146")

    automation.limits.maxChildren := 7
    after := winElement.getDescendants(automation.limits).length()
    Yunit.assert(after == 116, "Table + maxChildren = 7 -> 116")
    automation.limits.maxElements := 54
    after := winElement.getDescendants(automation.limits).length()
    Yunit.assert(after == 68, "Table + maxChildren = 7 + maxElements = 50 -> 68")

    automation.limits.maxDepth := 3
    ;after := winElement.getDescendants(automation.limits).length()
    ;Yunit.assert(after == 54, "Table + maxChildren = 7 + maxElements = 50 -> 54")

    rootNode := winElement.getDescendantsTree(automation.limits)

    list := RDA_ElementTreeNode.flattern(rootNode)
    Yunit.assert(list.length() == 4, "Table + maxChildren = 7 + maxElements = 50 + maxDepth = 3 -> 4")


    RDA_Log_Debug(winElement.dumpXML())

    lastException := 0
    try {
      winElement.findOne("//ToggleButton[@description=""JTable demo""]").click()
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Not found: //ToggleButton[@description=""JTable demo""]", "(limited search) Element not found")

    automation.limits.reset()
    winElement.findOne("//ToggleButton[@description=""JTable demo""]").click()

    ;uiaWin := win.asUIAElement()
    ;RDA_Log_Debug(uiaWin.dumpXML())

    win.close()

    ; do not stop javaswitch
    if (!full_reload) {
      RDA_AutomationJAB.JABSWITCH_ENABLED := 10
    }
  }

  End() {
  }
}
