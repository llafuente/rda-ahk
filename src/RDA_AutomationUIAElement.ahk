/*!
  Class: RDA_AutomationUIAElement
    Automate applications using Microsoft UI Automation

  Extends: RDA_AutomationBaseElement
*/
class RDA_AutomationUIAElement extends RDA_AutomationBaseElement {
  /*!
    Property: automation
      <RDA_Automation> - Automation config
  */
  automation := 0
  /*!
    Property: automation
      <RDA_AutomationWindow> - Window
  */
  win := 0
  /*!
    Property: uiaHandle
      number - UI Automation Handle
  */
  uiaHandle := 0

  ; internal
  cachedName := ""
  cachedType := ""
  cachedIndex := ""
  cachedPatterns := ""
  cachedDescription := ""

  __New(automation, win, uiaHandle) {
    this.uiaHandle := uiaHandle
    this.automation := automation
    this.win := win

    ; RDA_Log_Debug(A_ThisFunc . " " . this.toString())

    RDA_Assert(this.automation, A_ThisFunc . " automation is null")
    RDA_Assert(this.uiaHandle, A_ThisFunc . " uiaHandle is null")
    RDA_Assert(this.win, "invalid argument win is empty")
    RDA_Assert(this.win.hwnd, "invalid argument win.hwnd is empty")
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "RDA_AutomationUIAElement{name: " . this.getName() . ", type: " . this.getType() . ", patterns: " . RDA_JSON_stringify(RDA_Array_Join(this.getPatterns(), ",")) . "}"
  }
  ;
  ; Query
  ;
  /*!
    Method: getName
      Retrieves the element name

    Parameters:
      useCache - bool - use cached value (true) or fetch current value (false)

    Returns:
      string
  */
  getName(useCache := true) {
    if (!useCache || !this.cachedName) {
      this.cachedName := this.uiaHandle.CurrentName
    }

    RDA_Log_Debug(A_ThisFunc . "=" . this.cachedName)
    return this.cachedName
  }
  /*!
    Method: getDescription
      Retrieves the element description

    Returns:
      string
  */
  getDescription() {
    local

    if (!this.cachedDescription) {
      try {
        this.cachedDescription := this.uiaHandle.CurrentDescription
      } catch e {
      }
    }

    RDA_Log_Debug(A_ThisFunc . "=" . this.cachedDescription)
    return this.cachedDescription
  }
  /*!
    Method: getType
      Retrieves the element type

    Returns:
      string
  */
  getType() {
    local
    global UIA_Enum
    if (!this.cachedType) {
      this.cachedType := UIA_Enum.UIA_ControlTypeId(this.uiaHandle.CurrentControlType)
    }

    RDA_Log_Debug(A_ThisFunc . "=" . this.cachedType)
    return this.cachedType
  }
  /*!
    Method: getPatterns
      Retrieves the list of patterns implemented by the element

    Returns:
      string[]
  */
  getPatterns() {
    if (!this.cachedPatterns) {
      this.cachedPatterns := this.uiaHandle.GetSupportedPatterns()
    }

    return this.cachedPatterns
  }
  /*!
    Method: getIndex
      Retrieves current index at the tree

    Returns:
      number - -1 for root, the 1 index for the rest.
  */
  getIndex() {
    local

    if (!this.cachedIndex) {
      try {
        p := this.getParent()
      } catch e {
        RDA_Log_Error(A_ThisFunc . " " . e.message)
        ; root
        this.cachedIndex := -1
        RDA_Log_Debug(A_ThisFunc . " = " . this.cachedIndex)
        return this.cachedIndex
      }

      children := p.getChildren()
      loop % children.length() {
        if (this.isSameElement(children[A_Index])) {
          this.cachedIndex := A_Index
          RDA_Log_Debug(A_ThisFunc . " = " . this.cachedIndex)
          return this.cachedIndex
        }
      }
      throw RDA_Exception("Could not found myself in my parent children!")
    }

    RDA_Log_Debug(A_ThisFunc . " = " . this.cachedIndex)
    this.cachedIndex := A_Index

    return this.cachedIndex
  }
  /*!
    Method: getChildElementCount
      Retrieves the children count

    Returns:
      number
  */
  getChildElementCount() {
    local

    count := this.uiaHandle.GetChildren(0x2).length()
    RDA_Log_Debug(A_ThisFunc . "() = " . count)

    return count
  }
  /*!
    Method: getProperty
      Retrieves the current value of a property for this element

    Parameters:
      propName - string - property name

    Returns:
      string
  */
  getProperty(propName) {
    return this.uiaHandle.GetCurrentPropertyValue(propName)
  }
  /*!
    Method: isVisible
      Retrieves if the control is visible

    Returns:
      boolean
  */
  isVisible() {
    local v := !this.uiaHandle.CurrentIsOffscreen
    RDA_Log_Debug(A_ThisFunc . "=" . v)
    return v
  }
  /*!
    Method: isSameElement
      Retrieves if given element represents the same UI element

    Returns:
      boolean
  */
  isSameElement(other) {
    return this.automation.UIA.CompareElements(this.uiaHandle, other.uiaHandle)
  }
  ;
  ; Actions
  ;
  /*!
    Method: highlight
      Highlights the element

    Returns:
      <RDA_AutomationUIAElement>
  */
  highlight() {
    RDA_Log_Debug(A_ThisFunc)
    this.getRegion().highlight()

    return this
  }
  /*!
    Method: getRegion
      Retrieves screen region occupied by the element

    Returns:
      <RDA_ScreenRegion>
  */
  getRegion() {
    local
    global RDA_ScreenRegion, RDA_ScreenPosition, RDA_Rectangle

    br := this.uiaHandle.CurrentBoundingRectangle
    x := br.l
    y := br.t
    w := br.r-br.l
    h := br.b-br.t

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ", " . w . ", " . h . ")")

    return new RDA_ScreenRegion(new RDA_ScreenPosition(this.automation, br.l, br.t), new RDA_Rectangle(this.automation, w, h))
  }
  /*!
    Method: click
      "Clicks" on the element using UIA

    Remarks:
      This do not honor <RDA_Automation> configuration at it uses UIA

      It performs various things:
        * call Invoke: if InvokePattern is implemented
        * call Toggle: if TogglePattern is implemented
        * call Expand/Colapse: if ExpandCollapsePattern is implemented
        * call Select: if SelectItemPattern is implemented
        * call DoDefaultAction: if LegacyIAccessible is implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  click() {
    RDA_Log_Debug(A_ThisFunc)
    this.uiaHandle.click()

    return this
  }
  /*!
    Method: hover
      Alias of <RDA_AutomationBaseElement.osHover>

    Returns:
      <RDA_AutomationUIAElement>
  */
  hover() {
    return this.osHover()
  }
  /*!
    Method: focus
      Focuses control

    Returns:
      <RDA_AutomationUIAElement>
  */
  focus() {
    RDA_Log_Debug(A_ThisFunc)

    this.uiaHandle.SetFocus()

    return this
  }
  ; TODO move to global ?
  /*!
    Method: getFocusedControl
      Retrieves focused control

    Throws:
      No element focused

    Returns:
      <RDA_AutomationUIAElement>
  */
  getFocusedControl() {
    local
    global RDA_AutomationUIAElement

    v := this.automation.UIA.GetFocusedElement()

    if (IsObject(v)) {
      RDA_Log_Debug(A_ThisFunc)
      return new RDA_AutomationUIAElement(this.automation, this.win, v)
    }

    RDA_Log_Error(A_ThisFunc . " No element focused")
    throw RDA_Exception("No element focused")
  }

  ;
  ; Toggle
  ;
  /*!
    Method: toggle
      Toggles the element, element must implement TogglePattern

    Throws:
      TogglePattern not implemented
      Toggle called but no change

    Returns:
      <RDA_AutomationUIAElement>
  */
  toggle() {
    local
    global UIA_Enum

    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsTogglePatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Toggle")
        before := pattern.CurrentToggleState ? true : false
        pattern.Toggle()

        sleep % this.automation.actionDelay

        after := pattern.CurrentToggleState ? true : false
        if (before == after) {
          throw RDA_Exception("Toggle called but no change")
        }

        return this
      }

      throw RDA_Exception("TogglePattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: isChecked
      Retrieves if the element is checked, element must implement TogglePattern

    Throws:
      TogglePattern not implemented

    Returns:
      boolean
  */
  isChecked() {
    local
    global UIA_Enum

    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsTogglePatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Toggle")
        v := pattern.CurrentToggleState ? true : false

        RDA_Log_Debug(A_ThisFunc . " = " . (v ? "yes" : "no"))

        return v
      }

      throw RDA_Exception("TogglePattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  ; internal
  _ensureCheck(state) {
    local
    global UIA_Enum
    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsTogglePatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Toggle")
        if (pattern.CurrentToggleState != state) {
          pattern.Toggle()

          sleep % this.automation.actionDelay

          if (pattern.CurrentToggleState != state) {
            throw RDA_Exception("Toggle called but no change")
          }
        }

        return this
      }

      throw RDA_Exception("TogglePattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: ensureChecked
      Checks the element only if it's unchecked, element must implement TogglePattern

    Throws:
      Toggle failed, no change
      TogglePattern not implemented
  */
  ensureChecked() {
    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    this._ensureCheck(true)
  }
  /*!
    Method: ensureUnChecked
      Unchecks the element only if it's checked, element must implement TogglePattern

    Throws:
      Toggle failed, no change
      TogglePattern not implemented
  */
  ensureUnChecked() {
    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    this._ensureCheck(false)
  }

  ;
  ; SelectionItem
  ;

  ; internal
  _select(state) {
    local
    global UIA_Enum
    if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsSelectionItemPatternAvailablePropertyId)) {
      pattern := this.uiaHandle.GetCurrentPatternAs("SelectionItem")
      v := pattern.CurrentIsSelected ? true : false
      if (v != state) {
        pattern.select()

        sleep % this.automation.actionDelay
      }

      if (state == (pattern.CurrentIsSelected ? true : false)) {
        throw RDA_Exception("select called but no change")
      }

      return this
    }
    throw RDA_Exception("SelectionItemPattern not implemented")
  }
  /*!
    Method: select
      Selects the element, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented
      select called but no change

    Returns:
      <RDA_AutomationUIAElement>
  */
  select() {
    local
    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      this._select(true)
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
/*!
    Method: unselect
      Unselects the element, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented
      select called but no change

    Returns:
      <RDA_AutomationUIAElement>
  */
  unselect() {
    local
    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      this._select(false)
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: isSelected
      Retrieves if the element is selected, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  isSelected() {
    local
    global UIA_Enum

    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsSelectionItemPatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("SelectionItem")
        v := pattern.CurrentIsSelected ? true : false

        RDA_Log_Debug(A_ThisFunc . " = " . (v ? "yes" : "no"))

        return v
      }

      throw RDA_Exception("SelectionItemPattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: getSelectedItems
      Retrieves the list of selected elements, element must implement SelectionPattern

    Throws:
      SelectionPattern not implemented

    Returns:
      <RDA_AutomationUIAElement>[]
  */
  getSelectedItems() {
    local
    global UIA_Enum

    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsSelectionPatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Selection") ; UIA_SelectionPattern
        selection := pattern.GetCurrentSelection()

        RDA_Log_Debug(A_ThisFunc " found " . selection.length() . " elements")

        return this._wrapList(selection)
      }

      throw RDA_Exception("SelectionPattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: clearSelectedItems
      Retrieves if the element has multiple selection, element must implement SelectionPattern

    Remarks:
      It will loop the selected items an unselects,
      it may not remove the last one and throw

    Throws:
      SelectionPattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  clearSelectedItems() {
    local
    RDA_Log_Debug(A_ThisFunc)

    selection := this.getSelectedItems()
    loop % selection.length() {
      selection.unselect()
    }

    return this
  }
  /*!
    Method: canSelectMultiple
      Retrieves if the element has multiple selection, element must implement SelectionPattern

    Throws:
      SelectionPattern not implemented

    Returns:
      boolean
  */
  canSelectMultiple() {
    local
    global UIA_Enum

    RDA_Log_Debug(A_ThisFunc . "@" . this.toString())

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsSelectionPatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Selection") ; UIA_SelectionPattern
        v := pattern.CurrentCanSelectMultiple ? true : false

        RDA_Log_Debug(A_ThisFunc . " = " . (v ? "yes" : "no"))

        return v
      }

      throw RDA_Exception("SelectionPattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  ;
  ; TextPattern
  ;
  /*!
    Method: getSelectedText
      Retrieves the element selected text, element must implement TextPattern

    Throws:
      TextPattern not implemented
      getSelectedText failed

    Returns:
      string
  */
  getSelectedText() {
    local
    global UIA_Enum
    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsTextPatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Text") ; UIA_TextPattern
        selections := pattern.GetSelection() ; UIA_TextRangeArray
        selection := selections[1]
        return selection.GetText()
      }

      throw RDA_Exception("TextPattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  ;
  ; ValuePattern
  ;
  ; internal
  _setValue(text) {
    local
    global UIA_Enum
    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsValuePatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Value")
        pattern.SetValue(text)
        return this
      }

      throw RDA_Exception("ValuePattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " Could not setValue at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: setValue
      Sets element value, element must implement ValuePattern

    Remarks:
      This method can disclosure information, use <RDA_AutomationUIAElement.setPassword>

    Throws:
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  setValue(text) {
    RDA_Log_Debug(A_ThisFunc . "(" . text . ")")
    this._setValue(text)

    return this
  }
  /*!
    Method: setPassword
      Sets element value discreetly, element must implement ValuePattern

    Throws:
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  setPassword(text) {
    RDA_Log_Debug(A_ThisFunc . "( text.length = " . StrLen(text) . ")")
    this._setValue(text)

    return this
  }
  ; internal
  _getValue() {
    local
    global UIA_Enum

    try {
      if (this.uiaHandle.GetCurrentPropertyValue(UIA_Enum.UIA_IsValuePatternAvailablePropertyId)) {
        pattern := this.uiaHandle.GetCurrentPatternAs("Value")
        return pattern.CurrentValue
      }

      throw RDA_Exception("ValuePattern not implemented")
    } catch e {
      RDA_Log_Error(A_ThisFunc . " failed at " . this.toString())
      RDA_Log_Error(A_ThisFunc . " error = " . e.message)

      throw e
    }
  }
  /*!
    Method: getValue
      Retrieves element value, element must implement ValuePattern

    Remarks:
      This method can disclosure information, use <RDA_AutomationUIAElement.getPassword>

    Throws:
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  getValue() {
    local v := this._getValue()
    RDA_Log_Debug(A_ThisFunc . "=" . v)
    return v
  }
  /*!
    Method: getPassword
      Retrieves element value discreetly, element must implement ValuePattern

    Throws:
      getValue failed
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  getPassword() {
    local v := this._getValue()
    RDA_Log_Debug(A_ThisFunc . " length = " . StrLen(v))
    return v
  }
  ;
  ; tree
  ;

  /*!
    Method: getChildren
      Retrieves all the element child elements

    Returns:
      <RDA_AutomationUIAElement>[]
  */
  getChildren() {
    RDA_Log_Debug(A_ThisFunc . "()")

    return this._wrapList(this.uiaHandle.GetChildren(0x2))
  }
  /*!
    Method: getChild
      Retrieves a child by index

    Parameters:
      index - number - 1 Index

    Throws:
      Index out of bounds

    Returns:
      <RDA_AutomationUIAElement>
  */
  getChild(index) {
    local
    global RDA_AutomationUIAElement

    RDA_Log_Debug(A_ThisFunc . "(" . index . ")")

    elements := this.uiaHandle.GetChildren(0x2)

    if (index < 1 || index > elements.length()) {
      RDA_Log_Debug(A_ThisFunc . "Index out of bounds at " . this.toString())
      throw RDA_Exception("Index out of bounds")
    }

    return new RDA_AutomationUIAElement(this.automation, this.win, elements[index])
  }
  /*!
    Method: getDescendants
      Retrieves all element descendants

    Returns:
      <RDA_AutomationUIAElement>[]
  */
  getDescendants() {
    local

    RDA_Log_Debug(A_ThisFunc)
    /*
    stack := this.getChildren()
    ret := RDA_Array_Concat([], stack)

    while (stack.Length()) {
      element := stack.pop()

      elements := element.getChildren()

      stack := RDA_Array_Concat(stack, elements)
      ret := RDA_Array_Concat(ret, elements)
    }
    */
    ;ret := this._wrapList(this.uiaHandle.GetChildren(0x4))
    ret := this._wrapList(this.uiaHandle.FindAll())

    RDA_Log_Debug(A_ThisFunc . " Found " . ret.length() . " items")
    return ret
  }
  /*!
    Method: getSiblings
      Retrieves the element siblings (including myself)

    Throws:
      Could not get parent

    Returns:
      <RDA_AutomationUIAElement>[]
  */
  getSiblings() {
    return this.getParent().getChildren()
  }
  /*!
    Method: getParent
      Retrieves the element parent / Traverses up the tree once.

    Throws:
      Could not get parent

    Returns:
      <RDA_AutomationUIAElement>
  */
  getParent() {
    local
    global RDA_AutomationUIAElement

    v := this.uiaHandle.TreeWalkerTrue.GetParentElement(this.uiaHandle)

    if (IsObject(v)) {
      RDA_Log_Debug(A_ThisFunc)
      return new RDA_AutomationUIAElement(this.automation, this.win, v)
    }

    RDA_Log_Debug("Parent not found at " . this.toString())
    throw RDA_Exception("Could not get parent")
  }
  ; internal
  _wrapList(list) {
    local
    global RDA_AutomationUIAElement

    wrapList := []
    loop % list.length() {
      wrapList.push(new RDA_AutomationUIAElement(this.automation, this.win, list[A_Index]))
    }

    return wrapList
  }

  /*
  ;
  ; Event handler, removed as its not reliable!
  ;
  onFocusChange(funcName) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . funcName . ")")

    fn := Func(funcName)
    ; RDA_Assert(funcName.MinParams == 1, A_ThisFunc " given callback shall have one parameter")

    handler := UIA_CreateEventHandler(funcName, "FocusChanged")
    this.automation.UIA.AddFocusChangedEventHandler(handler)
  }

  */

}
