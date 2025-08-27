/*

API / info / usage
* https://hg.openjdk.org/jdk9/jdk9/jdk/file/tip/src/jdk.accessibility/windows/native/bridge/AccessBridgeCalls.c
* https://github.com/openjdk/jdk/blob/master/src/jdk.accessibility/windows/native/bridge/AccessBridgeCalls.c
* https://docs.oracle.com/javase/10/access/java-access-bridge-api.htm
* https://github.com/robocorp/rpaframework/blob/master/packages/main/src/RPA/JavaAccessBridge.py
* https://github.com/google/access-bridge-explorer/blob/fa69aec21320ce33d50f37430ee6f1d1aafd5b8f/src/WindowsAccessBridgeInterop/AccessibleContextNode.cs

*/

/*!
  class: RDA_AutomationJABElement
    Automation configuration for java access bridge.

  Extends: RDA_AutomationBaseElement
*/
class RDA_AutomationJABElement extends RDA_AutomationBaseElement {
  ; static __Call := TooFewArguments(RDA_AutomationJABElement)
  /*!
    Constant: HIGHLIGHT_SETVALUE
      number - highlights element given miliseconds before setting value
  */
  HIGHLIGHT_SETVALUE := 0
  /*!
    Constant: HIGHLIGHT_CLICK
      number - highlights element given miliseconds before clicking
  */
  HIGHLIGHT_CLICK := 0

  /*!
    Property: jab
      <RDA_AutomationJAB>
  */
  jab := 0
  /*!
    Property: win
      <RDA_AutomationWindow> Root Window,

    Remarks:
      Inside JAB you can navigate to modals/popup/other windows
      this points to the windows used to create the first element

  */
  win := 0
  /*!
    Property: vmId
      Virtual machine id
  */
  vmId := 0
  /*!
    Property: acId
      Accessible context ID
  */
  acId := 0

  ; internal
  _info := 0
  /*!
    Constructor: RDA_AutomationJABElement

    Parameters:
    jab - <RDA_AutomationJAB> -
    win - <RDA_AutomationWindow> - Window
    vmId - number - Virtual machine id
    acId - number - Accessible context ID
  */
  __New(jab, win, vmId, acId) {
    this.automation := jab.automation
    this.jab := jab
    this.win := win
    this.vmId := vmId
    this.acId := acId

    RDA_Assert(this.jab, "invalid argument jab is empty")
    RDA_Assert(this.automation, "invalid argument jab is empty")
    RDA_Assert(this.win, "invalid argument win is empty")
    RDA_Assert(this.win.hwnd, "invalid argument win.hwnd is empty")
    RDA_Assert(this.vmId, "invalid argument vmId is empty")
    RDA_Assert(this.acId, "invalid argument acId is empty")

  }
  __Delete() {
    ; DllCall(this.jab.dllName . "\ReleaseJavaObject", "Int", this.vmId, this.JAB.acType, this.acId, "Cdecl")
  }
  /*!
    Method: toString
      Dumps the object to a readable string
  */
  toString() {
    return "RDA_AutomationJABElement{hwnd:" . this.win.hwnd . ", vmId:" . this.vmId . ", acId:" . this.acId . "}"
  }
  ;
  ; query
  ;
  /*!
    Method: getId
      Do not exists in JAB it's only for interface compatibility

    Parameters:
      useCache - bool - use cached value (true) or fetch current value (false)

    Returns:
      string
  */
  getId(useCache := true) {
    RDA_Log_Debug(A_ThisFunc)

    return ""
  }
  _name := 0
  /*!
    Method: getName
      Retrieves the element name

    Parameters:
      useCache - bool - use cached value (true) or fetch current value (false)

    Returns:
      string
  */
  getName(useCache := true) {
    RDA_Log_Debug(A_ThisFunc)

    this.__cacheInfo(!useCache)
    name := this._info.name
    /*
    name := ""

    if (!name) {
      if (!useCache || !this._name) {
        buff := 0
        VarSetCapacity(buff, RDA_AutomationJAB.MAX_STRING_SIZE * 2, 0)
        ;BOOL GetVirtualAccessibleName(long vmID, AccessibleValue av, wchar_t *value, short len);
        if (!DllCall(this.jab.dllName . "\getVirtualAccessibleName"
          , "Int", this.vmId, this.jab.acType, this.acId
          , "ptr", &buff, "short", RDA_AutomationJAB.MAX_STRING_SIZE
          , "Cdecl Int")) {
          throw RDA_Exception("getVirtualAccessibleName failed")
        }
        this._name := StrGet(&buff, RDA_AutomationJAB.MAX_STRING_SIZE, "UTF-16")
      }

      name := this._name
    }
    */

    RDA_Log_Debug(A_ThisFunc . "=" . name)

    return name
  }
  /*!
    Method: getDescription
      Retrieves the element description

    Returns:
      string
  */
  getDescription() {
    this.__cacheInfo()
    RDA_Log_Debug(A_ThisFunc . "=" . this._info.description)

    return this._info.description
  }
  /*!
    Method: getType
      Retrieves the element type

    Returns:
      string
  */
  getType() {
    local

    this.__cacheInfo()

    type := " " . this._info.role
    while (c := InStr(type, " ")) {
      type := SubStr(type, 1, c - 1) . Format("{:U}", SubStr(type, c + 1, 1)) . SubStr(type, c + 2)
    }

    RDA_Log_Debug(A_ThisFunc . "=" . type)


    return type
  }
  /*!
    Method: getPatterns
      Retrieves the list of patterns implemented by the element

    Remarks:
      In use JAB states to fill the array

    Returns:
      string[]
  */
  getPatterns() {
    local

    ret := []
    this.__cacheInfo()
    s := this._info.states
    r := this._info.role

    RDA_Log_Debug(A_ThisFunc . " states = " . s . " role = " . r)

    ; InStr(s, "editable")
    if (this._info.accessibleValueInterface) {
      ret.push("Value")
    }
    if (this._info.accessibleTextInterface) {
      ret.push("Text")
    }
    if (InStr(s, "selectable")) {
      ret.push("SelectionItem")
    }
    if (InStr(s, "focusable")) {
      ret.push("Invoke") ; <-- click
    }
    if (InStr(s, "expandable")) {
      ret.push("ExpandCollapsed") ; <-- click
    }
    if (r == "check box" || r == "toggle button" || r == "radio button"|| r == "push button") {
      ret.push("Toggle")
    }
    ; r == "combo box" || r == "list") {
    if (this._info.accessibleSelectionInterface) {
      ret.push("Selection")
    }

    RDA_Log_Debug(A_ThisFunc . " = " . RDA_JSON_stringify(ret))

    return ret
  }

  /*!
    Method: getIndex
      Retrieves current index at the tree

    Returns:
      number - the 1 index for the rest.
  */
  getIndex() {
    this.__cacheInfo()
    RDA_Log_Debug(A_ThisFunc . " = " . this._info.indexInParent + 1)

    return this._info.indexInParent + 1
  }

  /*!
    Method: getChildElementCount
      Retrieves the children count

    Returns:
      number
  */
  getChildElementCount() {
    this.__cacheInfo()
    return this._info.childrenCount
  }
  /*!
    Method: getProperty
      Not used.

    Parameters:
      propName - string - property name

    Throws:
      No apply

    Returns:
      string
  */
  getProperty(propName) {
    throw RDA_Exception("No apply")
  }
  /*!
    Method: isVisible
      Retrieves if the control is visible.

    Remarks:
      That's not means it's clickable! It can be occluded by other element.

    Returns:
      boolean
  */
  isVisible() {
    ; TODO
    throw RDA_Exception("TODO")
  }
  /*!
    Method: isSameElement
      Retrieves if given element represents the same UI element

    Parameters:
      other - <RDA_AutomationJABElement> - element

    Returns:
      boolean
  */
  isSameElement(other) {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString() . " (" . other.toString() . ")")

    ; BOOL isSameObject(vmID, obj1, obj2);
    return DllCall(this.jab.dllName . "\isSameObject"
      , "Int", this.vmId, this.jab.acType, this.acId, this.jab.acType, other.acId, "Cdecl Int")
  }

  ; internal, no log
  __cacheInfo(rebuild := false) {
    if (rebuild) {
      this._info := 0
    } else if (this._info) {
      return
    }

    this._info := this.getInfo()
  }

  ;
  ; Actions
  ;
  /*!
    Method: highlight
      Highlights the element

    Returns:
      <RDA_AutomationJABElement>
  */
  highlight() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

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

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo()

    r := new RDA_ScreenRegion(new RDA_ScreenPosition(this.automation, this._info.x, this._info.y), new RDA_Rectangle(this.automation, this._info.width, this._info.height))

    RDA_Log_Debug(A_ThisFunc . " = " . r.toString())

    return r
  }

  /*!
    Method: click
      "Clicks" on the element using JAB

    Remarks:
      This do not honor <RDA_Automation> configuration at it uses JAB doAction

      It will try to do one of the following actions (first available)

      * click
      * hacer click
      * toogleexpand

    Throws:
      Could not find a compatible action: click / hacer clic
      Action failed

    Returns:
      <RDA_AutomationJABElement>
  */
  click() {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    if (RDA_AutomationJABElement.HIGHLIGHT_CLICK > 0) {
      this.highlight(RDA_AutomationJABElement.HIGHLIGHT_CLICK)
    }

    ; for an unknown reason this string is multi-language!
    availableActions := this.getActions()
    actions := ["click", "hacer clic", "toggleexpand"]
    done := false
    loop % actions.length() {
      action := actions[A_Index]
      if (RDA_Array_IndexOf(availableActions, action)) {
        this.doActions([action])
        done := true
        break
      }
    }

    if (!done) {
      throw RDA_Exception("Could not find a compatible action: " . RDA_Array_Join(actions, ", "))
    }

    sleep % this.automation.actionDelay

    return this
  }
  /*!
    Method: hover
      Alias of <RDA_AutomationBaseElement.osHover>, JAB do not have hover.

    Returns:
      <RDA_AutomationJABElement>
  */
  hover() {
    return this.osHover()
  }
  /*!
    Method: focus
      Focuses control

    Throws:
      focus failed

    Returns:
      <RDA_AutomationJABElement>
  */
  focus() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    if (!DllCall(this.jab.dllName "\requestFocus", "Int"
      , this.vmId, this.jab.acType, this.acId, "Cdecl Int")) {
      throw RDA_Exception("focus failed")
    }

    return this
  }

  ; TODO getFocusedControl?

  ;
  ; Toggle
  ;
  /*!
    Method: toggle
      Toggles the element, element must implement TogglePattern

    Throws:
      TogglePattern not implemented
      toggle() called but no change

    Returns:
      <RDA_AutomationJABElement>
  */
  toggle() {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    before := this.isChecked()

    try {
      this.click()
    } catch e {
      RDA_Log_Error(A_ThisFunc . " " . e.message)
    }

    after := this.isChecked()

    if (before == after) {
      throw RDA_Exception("toggle() called but no change")
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

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo(true)

    this.expectPattern("Toggle", "TogglePattern not implemented")

    return InStr(this._info.states, "checked") > 0
  }
  ; internal
  _ensureCheck(state) {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    if (this.isChecked() != state) {
      try {
        this.click()
      } catch e {
        RDA_Log_Error(A_ThisFunc . " " . e.message)
      }
    }

    if (this.isChecked() != state) {
      throw RDA_Exception("toggle() called but no change")
    }
  }
  /*!
    Method: ensureChecked
      Checks the element only if it's unchecked, element must implement TogglePattern

    Throws:
      toggle() called but no change
      TogglePattern not implemented
  */
  ensureChecked() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this._ensureCheck(true)
  }
  /*!
    Method: ensureUnChecked
      Unchecks the element only if it's checked, element must implement TogglePattern

    Throws:
      toggle() called but no change
      TogglePattern not implemented
  */
  ensureUnChecked() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this._ensureCheck(false)
  }
  ;
  ; ExpandCollapsed
  ;

  _ensureExpanded(state) {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    if (this.isExpanded() != state) {
      try {
        this.click()
      } catch e {
        RDA_Log_Error(A_ThisFunc . " " . e.message)
      }
    }

    if (this.isExpanded() != state) {
      throw RDA_Exception("click() called but no change")
    }
  }
  /*!
    Method: ensureExpanded
      Expand the element only if it's collapsed, element must implement ExpandCollapsed

    Throws:
      click() called but no change
      ExpandCollapsedPattern not implemented
  */
  ensureExpanded() {
    this.expectPattern("ExpandCollapsed", "ExpandCollapsedPattern not implemented")
    this._ensureExpanded(true)
  }
  /*!
    Method: ensureCollapsed
      Collapse the element only if it's expanded, element must implement ExpandCollapsed

    Throws:
      Click failed, no change
      ExpandCollapsedPattern not implemented
  */
  ensureCollapsed() {
    this.expectPattern("ExpandCollapsed", "ExpandCollapsedPattern not implemented")
    this._ensureExpanded(false)
  }

  /*!
    Method: isExpanded
      Retrieves if the element is expanded, element must implement ExpandCollapsed

    Throws:
      ExpandCollapsedPattern not implemented

    Returns:
      boolean
  */
  isExpanded() {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo(true)

    this.expectPattern("ExpandCollapsed", "ExpandCollapsedPattern not implemented")

    return InStr(this._info.states, "expanded") > 0
  }
  /*!
    Method: isCollapsed
      Retrieves if the element is collapsed, element must implement ExpandCollapsed

    Throws:
      ExpandCollapsed not implemented

    Returns:
      boolean
  */
  isCollapsed() {
    ; state=collapsed => !expanded
    return this.isExpanded()
  }

  ;
  ; SelectionItem
  ;
  /*!
    Method: select
      Selects the element, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented
      select() called but no change

    Returns:
      <RDA_AutomationJABElement>
  */
  select() {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo()

    this.expectPattern("SelectionItem", "SelectionItemPattern not implemented")

    parent := this.getParent()
    parent.expectPattern("Selection", "SelectionPattern not implemented")

    ; void AddAccessibleSelectionFromContext(long vmID, AccessibleSelection as, int i);
    DllCall(this.jab.dllName . "\addAccessibleSelectionFromContext"
      , "Int", this.vmId, this.jab.acType, parent.acId, "Int", this._info.indexInParent
      , "Cdecl Int")

    if (!this.isSelected()) {
      throw RDA_Exception("select() called but no change")
    }

    return this
  }
  /*!
    Method: unselect
      Unselects the element, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented
      unselect called but no change

    Returns:
      <RDA_AutomationJABElement>
  */
  unselect() {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo()

    parent := this.getParent()

    ; void RemoveAccessibleSelectionFromContext(long vmID, AccessibleSelection as, int i);
    DllCall(this.jab.dllName . "\removeAccessibleSelectionFromContext"
      , "Int", this.vmId, this.jab.acType, parent.acId, "Int", this._info.indexInParent
      , "Cdecl Int")

    if (this.isSelected()) {
      throw RDA_Exception("unselect called but no change")
    }

    return this
  }
  /*!
    Method: isSelected
      Retrieves if the element is selected, element must implement SelectionItemPattern

    Throws:
      SelectionItemPattern not implemented

    Returns:
      <RDA_AutomationJABElement>
  */
  isSelected() {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    this.__cacheInfo(true)

    this.expectPattern("SelectionItem", "SelectionItemPattern not implemented")

    return InStr(this._info.states, "selected") > 0

  }
  /*!
    Method: getSelectedItems
      Retrieves the list of selected elements, element must implement SelectionPattern

    Remarks:
      "Selection returns an empty object" means that most likely a ComboBox is
      not initialized or unselected so the selection is empty but java need one value.

    Throws:
      SelectionPattern not implemented
      Selection returns an empty object

    Returns:
      <RDA_AutomationJABElement>[]
  */
  getSelectedItems() {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this.expectPattern("Selection", "SelectionPattern not implemented")

    ; int GetAccessibleSelectionCountFromContext(long vmID, AccessibleSelection as);
    count := DllCall(this.jab.dllName . "\getAccessibleSelectionCountFromContext"
      , "Int", this.vmId, this.jab.acType, this.acId
      , "Cdecl Int")

    RDA_Log_Debug(A_ThisFunc . " selected " . count . " elements")

    list := []
    loop % count {
      ; jobject GetAccessibleSelectionFromContext(long vmID, AccessibleSelection as, int i);
      acId := DllCall(this.jab.dllName . "\getAccessibleSelectionFromContext"
        , "Int", this.vmId, this.jab.acType, this.acId, "Int", A_Index - 1
        , "Cdecl " . this.jab.acType)
      if (!acId) {
        throw RDA_Exception("Selection returns an empty object")
      }
      list.Push(new RDA_AutomationJABElement(this.jab, this.win, this.vmId, acId))
    }

    return list
  }
  /*!
    Method: clearSelectedItems
      Retrieves if the element has multiple selection, element must implement SelectionPattern

    Remarks:
      it may not remove all if the app has some defaults

    Throws:
      SelectionPattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  clearSelectedItems() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this.expectPattern("Selection", "SelectionPattern not implemented")

    ; void ClearAccessibleSelectionFromContext(long vmID, AccessibleSelection as)
    DllCall(this.jab.dllName . "\clearAccessibleSelectionFromContext"
      , "Int", this.vmId, this.jab.acType, this.acId
      , "Cdecl Int")

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
    local pattern, v, e

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this.__cacheInfo()
    this.expectPattern("Selection", "SelectionPattern not implemented")

    return InStr(this._info.states, "multiselectable") > 0
  }
  ; internal
  _ensureSelect(state) {
    local

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    if (this.isSelected() != state) {
      try {
        this.select()
      } catch e {
        RDA_Log_Error(A_ThisFunc . " " . e.message)
      }
    }

    if (this.isSelected() != state) {
      throw RDA_Exception("select called but no change")
    }
  }
  /*!
    Method: ensureSelected
      Selects the element only if it's unselected, element must implement SelectionItemPattern

    Throws:
      select called but no change
      SelectionItemPattern not implemented
  */
  ensureSelected() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this._ensureSelect(true)
  }
  /*!
    Method: ensureUnChecked
      Unselects the element only if it's selected, element must implement SelectionItemPattern

    Throws:
      select called but no change
      SelectionItemPattern not implemented
  */
  ensureUnselected() {
    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())

    this._ensureSelect(false)
  }
  ;
  ; TextPattern
  ;
  /*!
    Method: getSelectedText
      Retrieves the element selected text, element must implement TextPattern

      Not implemented

    Throws:
      not implemented

    Returns:
      string
  */
  getSelectedText() {
    local

    throw RDA_Exception("not implemented")
  }
  ;
  ; ValuePattern
  ;
  ; internal
  _setValue(text) {
    local

    this.__cacheInfo()

    if (this._info.accessibleTextInterface) {
      l := StrLen(text)
      VarSetCapacity(buff, l * 2, 0)
      StrPut(text, &buff, l, "UTF-16")
      ; BOOL setTextContents (const long vmID, const AccessibleContext accessibleContext, const wchar_t *text);
      if (!DllCall(this.jab.dllName . "\setTextContents"
        , "Int", this.vmId, this.jab.acType, this.acId, "ptr", &buff
        , "Cdecl Int")) {
        ; it's a fail but need to match UIA
        throw RDA_Exception("setTextContents failed")
      }
      return
    }

    if (this._info.accessibleValueInterface) {
      ; TODO
    }

    throw RDA_Exception("ValuePattern or TextPattern not implemented")
  }
  /*!
    Method: setValue
      Sets element value, element must implement ValuePattern

    Remarks:
      This method can disclosure information, use <RDA_AutomationUIAElement.setPassword>

    Throws:
      setTextContents failed
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  setValue(text) {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . "(" . text . ")")

    if (RDA_AutomationJABElement.HIGHLIGHT_SETVALUE > 0) {
      this.highlight(RDA_AutomationJABElement.HIGHLIGHT_SETVALUE)
    }

    this._setValue(text)

    return this
  }
  /*!
    Method: setPassword
      Sets element value discreetly, element must implement ValuePattern

    Throws:
      setTextContents failed
      ValuePattern not implemented

    Returns:
      <RDA_AutomationUIAElement>
  */
  setPassword(text) {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . "( text.length = " . StrLen(text) . ")")

    if (RDA_AutomationJABElement.HIGHLIGHT_SETVALUE > 0) {
      this.highlight(RDA_AutomationJABElement.HIGHLIGHT_SETVALUE)
    }

    this._setValue(text)

    return this
  }
  ; internal
  _getValue() {
    local
    global RDA_AutomationJAB
    RDA_Log_Debug(A_ThisFunc)

    if (this._info.accessibleTextInterface) {
      CharCount := CaretIndex := IndexAtPoint := 0
      VarSetCapacity(Info, 12,0)
      if (DllCall(this.jab.dllName . "\getAccessibleTextInfo"
        , "Int", this.vmId, this.jab.acType, this.acId
        , "Ptr", &Info, "Int", 0, "Int", 0
        , "Cdecl Int")) {
            CharCount := NumGet(&Info,0,"Int")
            CaretIndex := NumGet(&Info,4,"Int")
            IndexAtPoint := NumGet(&Info,8,"Int")
      } else {
        throw RDA_Exception("getAccessibleTextInfo failed")
      }

      VarSetCapacity(Info, 0,0)
      Info := 0

      ; now get the entire text!
      maxlen:=10000 ; arbitrary value, larger values tend to fail sometimes
      cnt := 0
      ret := ""
      nullByte := Chr(0)
      Loop {
        if (cnt + maxlen > CharCount) {
          cnt2 := CharCount-1
        } else {
          cnt2 := cnt+maxlen
        }
        len:=maxlen+1
        text := 0
        VarSetCapacity(text, len*2,0)
        if (DllCall(this.jab.dllName . "\getAccessibleTextRange"
          , "Int", this.vmId, this.jab.acType, this.acId
          , "Int", cnt, "Int", cnt2, "Ptr", &text, "Int", len
          , "Cdecl Int")) {
          NumPut(0, text, (cnt2 - cnt + 1) * 2, "UChar")
          ; occasionally the first call fails at the end of the text
          if ((cnt2 > cnt) and (NumGet(text, 0, "UChar") == 0)) {
            DllCall(this.jab.dllName . "\getAccessibleTextRange"
              , "Int", this.vmId, this.jab.acType, this.acId
              , "Int", cnt, "Int", cnt2, "Ptr", &text, "Int", len
              , "Cdecl Int")
            NumPut(0,text,(cnt2-cnt+1)*2, "UChar")
          }

          Loop, % maxlen+1
          {
            jver:=Chr(NumGet(&text, (A_Index - 1) * 2, "UChar"))
            if (jver == nullByte) {
              break
            }
            ret .= jver
          }
        }
        if (cnt>=cnt2) {
          cnt++
        } else {
          cnt:=cnt2+1
        }
        if (cnt>=CharCount-1)
          break
      }

      return ret
    }

    if (this._info.accessibleValueInterface) {
      ; this should be the way, but it's always empty...
      buff := 0
      VarSetCapacity(buff, RDA_AutomationJAB.MAX_STRING_SIZE * 2, 0)
      ; GetMaximumAccessibleValueFromContext
      ; GetMinimumAccessibleValueFromContext

      ;BOOL GetCurrentAccessibleValueFromContext(long vmID, AccessibleValue av, wchar_t *value, short len);
      if (!DllCall(this.jab.dllName . "\getCurrentAccessibleValueFromContext"
        , "Int", this.vmId, this.jab.acType, this.acId
        , "ptr", &buff, "short", RDA_AutomationJAB.MAX_STRING_SIZE
        , "Cdecl Int")) {
        ; it's a fail but need to match UIA
        throw RDA_Exception("ValuePattern not implemented")
      }

      return StrGet(&buff, RDA_AutomationJAB.MAX_STRING_SIZE, "UTF-16")
    }

    throw RDA_Exception("ValuePattern or TextPattern not implemented")
  }
  /*!
    Method: getValue
      Retrieves element value, element must implement ValuePattern

    Remarks:
      This method can disclosure information, use <RDA_AutomationUIAElement.getPassword>

    Throws:
      Could not find a compatible action
      Action failed

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
      Could not find a compatible action
      Action failed

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
      <RDA_AutomationJABElement>[]
  */
  getChildren() {
    local

    ret := []
    loop % this.getChildElementCount() {
      ret.push(this.getChild(A_Index))
    }
    RDA_Log_Debug(A_ThisFunc . " Found " . ret.length() . " elements")

    return ret
  }
  /*!
    Method: getChild
      Retrieves a child by index

    Parameters:
      index - number - 1 Index

    Throws:
      Index out of bounds

    Returns:
      <RDA_AutomationJABElement>
  */
  getChild(index) {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . "(" . this.toString() . ", " . index . ")")

    acId := DllCall(this.jab.dllName . "\getAccessibleChildFromContext"
      , "Int", this.vmId, this.jab.acType, this.acId, "Int", index - 1
      , "Cdecl " . this.jab.acType)

    if (!acId) {
      throw RDA_Exception("Index out of bounds")
    }

    return new RDA_AutomationJABElement(this.jab, this.win, this.vmId, acId)
  }
  /*!
    Method: getDescendants
      Retrieves all element descendants

    Parameters:
      limits - <RDA_SearchLimits> - Configure limits for descendant discovery.

    Returns:
      <RDA_AutomationJABElement>[]
  */
  getDescendants(limits := 0) {
    local
    global RDA_ElementTreeNode

    RDA_Log_Debug(A_ThisFunc . "(" . limits ? limits.toString() : "no" . ")")

    list := RDA_ElementTreeNode.flatternToElements(this._getDescendantsTree(limits))

    RDA_Log_Debug(A_ThisFunc . " Found " . list.length() . " items")
    return list
  }
  /*!
    Method: getSiblings
      Retrieves the element siblings (including myself)

    Throws:
      Could not get parent

    Returns:
      <RDA_AutomationJABElement>[]
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
      RDA_AutomationJABElement
  */
  getParent() {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . "(" . this.toString() . ")")

    acId := DllCall(this.jab.dllName . "\getAccessibleParentFromContext"
      , "Int", this.vmId, this.jab.acType, this.acId
      , "Cdecl " . this.jab.acType)
    if (!acId) {
      throw RDA_Exception("Could not get parent")
    }

    return new RDA_AutomationJABElement(this.jab, this.win, this.vmId, acId)
  }

  ;
  ; Custom, JAB specific
  ;
  /*!
    Method: doActions
      Requests the element to perform given actions

    Parameters:
      actions - string[] - action list

    Throws:
      Element do not implement ActionInterface
      Action failed: ?
  */
  doActions(actions) {
    local
    global RDA_AutomationJAB

    RDA_Log_Debug(A_ThisFunc . "(" . this.toString() . ", " . RDA_JSON_stringify(actions) . ")")

    this.__cacheInfo()
    if (!this._info.accessibleActionInterface) {
      throw RDA_Exception("Element do not implement ActionInterface")
    }

    VarSetCapacity(buff, 256*256*2+4, 0)
    NumPut(actions.length(), &buff, 0, "Int")
    loop % actions.length() {
      action := actions[A_Index]
      index := A_Index - 1
      ;offset := 4
      Loop % StrLen(action)
      {
        offset:= 4 + (A_Index - 1) * 2 + RDA_AutomationJAB.SHORT_STRING_SIZE * 2 * index
        ch := SubStr(action, A_Index, 1)
        chv := Asc(ch)
        ; RDA_Log_Debug("offset: " . offset . " val " . chv . " char " . ch)
        NumPut(chv, &buff, offset, "UChar")
        ;offset += 2
      }
      ; NumPut(0, &actions, offset, "UChar")
  }

    VarSetCapacity(failure, A_PtrSize, 0)
    ; BOOL doAccessibleActions(long vmID, AccessibleContext accessibleContext, AccessibleActionsToDo *actionsToDo, jint *failure);
    ; Request that a list of AccessibleActions be performed by a component.
    ; Returns TRUE if all actions are performed. Returns FALSE when the first requested action
    ; fails in which case "failure" contains the index of the action that failed.

    ; Reality: always returns false and failure is -1 when there is no error.
    local r := DllCall(this.jab.dllName . "\doAccessibleActions"
      , "Int", this.vmId, this.jab.acType, this.acId, "Ptr", &buff, "Int*", failure
      , "Cdecl Int")
    RDA_Log_Debug(A_ThisFunc . " doAccessibleActions(result = " . r . ", failure = " . failure . ")")
    VarSetCapacity(buff, 0)
    buff := 0
    if (failure != -1) {
      throw RDA_Exception("Action failed: " . actions[failure + 1])
    }
  }

  /*!
    Method: getActions
      Returns a list of actions that a component can perform.

    Returns:
      string[] - list of actions
  */
  getActions() {
    local
    global RDA_AutomationJAB

    RDA_Log_Debug(A_ThisFunc . " @ " . this.toString())
    list := []

    actions := 0
    VarSetCapacity(actions, RDA_AutomationJAB.SHORT_STRING_SIZE*RDA_AutomationJAB.SHORT_STRING_SIZE*2+A_PtrSize,0)

    if DllCall(this.jab.dllName "\getAccessibleActions"
      , "Int", this.vmId, this.jab.acType, this.acId, "Ptr", &actions, "Cdecl Int")
    {
      count := NumGet(&actions,0,"Int")

      Loop, % count
      {
        ;this.extract(this["SHORT_STRING_SIZE"])

        str := ""
        index := A_Index - 1
        Loop, % RDA_AutomationJAB.SHORT_STRING_SIZE
        {
          ; A_PtrSize
          offset:= 4 + (A_Index - 1) * 2  + RDA_AutomationJAB.SHORT_STRING_SIZE * 2 * index
          x := NumGet(&actions,offset,"UChar")

          jver:=Chr(x)
          if (jver=Chr(0))
          {
              break
          }
          str.= jver
        }
        list.push(str)
      }
    }

    VarSetCapacity(actions, 0)
    actions := 0

    RDA_Log_Debug(A_ThisFunc . " output[" . count . "] = " . RDA_JSON_stringify(list))

    Return list
  }
  /*!
    Method: setValue2
      Alternative method to <RDA_AutomationUIAElement.setValue>

    Remarks:
      It uses the clipboard and *paste-from-clipboard* action

    Throws:
      Could not find a compatible action: paste-from-clipboard
      Action failed

    Returns:
      <RDA_AutomationUIAElement>
  */
  setValue2(text) {
    ; alternative method - slow
    actions := this.getActions()
    if (!RDA_Array_IndexOf(actions, "paste-from-clipboard")) {
      throw RDA_Exception("Could not find a compatible action: paste-from-clipboard")
    }

    Clipboard := text
    this.doActions(["paste-from-clipboard"])
    Clipboard := ""

    return this
  }
  /*!
    Method: getValue2
      Alternative method to <RDA_AutomationUIAElement.getValue>

    Remarks:
      It uses the clipboard and *select-all*, *copy-to-clipboard* actions.

    Throws:
      Could not find a compatible action: select-all
      Could not find a compatible action: copy-to-clipboard
      Action failed

    Returns:
      string
  */
  getValue2() {
    actions := this.getActions()
    if (!RDA_Array_IndexOf(actions, "select-all")) {
      throw RDA_Exception("Could not find a compatible action: select-all")
    }
    if (!RDA_Array_IndexOf(actions, "copy-to-clipboard")) {
      throw RDA_Exception("Could not find a compatible action: copy-to-clipboard")
    }

    Clipboard := ""
    this.doActions(["select-all", "copy-to-clipboard"])
    ret := Clipboard
    Clipboard := ""

    return ret
  }

  /*!
    Method: getInfo
      Retrieves element info

    Throws:
      getAccessibleContextInfo failed

    Returns:
      <RDA_AutomationJABAccessibleContextInfo>
  */
  getInfo() {
    local
    global RDA_AutomationJABAccessibleContextInfo, RDA_AutomationJAB

    RDA_Log_Debug(A_ThisFunc "(" . this.toString() . ")")

    this._info := new RDA_AutomationJABAccessibleContextInfo()
    VarSetCapacity(Info, 6188,0)
    if (!DllCall(this.jab.dllName . "\getAccessibleContextInfo"
      , "Int", this.vmId, this.jab.acType, this.acId, "Ptr", &Info
      , "Cdecl " . this.jab.acType)) {
      throw RDA_Exception("getAccessibleContextInfo failed")
    }

    ; https://github.com/openjdk/jdk/blob/master/src/jdk.accessibility/windows/native/include/bridge/AccessBridgePackages.h#L651
    offset := 0
    ; wchar_t name[MAX_STRING_SIZE];          // the AccessibleName of the object
    this._info.name := StrGet(&Info, RDA_AutomationJAB.MAX_STRING_SIZE, "UTF-16")
    offset += RDA_AutomationJAB.MAX_STRING_SIZE * 2
    ; wchar_t description[MAX_STRING_SIZE];   // the AccessibleDescription of the object
    this._info.description := StrGet((&Info) + offset, RDA_AutomationJAB.MAX_STRING_SIZE, "UTF-16")
    offset += RDA_AutomationJAB.MAX_STRING_SIZE * 2
    ; wchar_t role[SHORT_STRING_SIZE];        // localized AccesibleRole string
    ; skip
    offset += RDA_AutomationJAB.SHORT_STRING_SIZE * 2
    ; wchar_t role_en_US[SHORT_STRING_SIZE];  // AccesibleRole string in the en_US locale
    this._info.role := StrGet((&Info)+ offset, RDA_AutomationJAB.SHORT_STRING_SIZE, "UTF-16")
    offset += RDA_AutomationJAB.SHORT_STRING_SIZE * 2
    ; wchar_t states[SHORT_STRING_SIZE];      // localized AccesibleStateSet string (comma separated)
    offset += RDA_AutomationJAB.SHORT_STRING_SIZE * 2
    ; wchar_t states_en_US[SHORT_STRING_SIZE]; // AccesibleStateSet string in the en_US locale (comma separated)
    this._info.states := StrGet((&Info)+ offset, RDA_AutomationJAB.SHORT_STRING_SIZE, "UTF-16")
    offset += RDA_AutomationJAB.SHORT_STRING_SIZE * 2
    ; jint indexInParent;                     // index of object in parent
    this._info.indexInParent := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint childrenCount;                     // # of children, if any
    this._info.childrenCount := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint x;                                 // screen coords in pixels
    this._info.x := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint y;                                 // "
    this._info.y := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint width;                             // pixel width of object
    this._info.width := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint height;                            // pixel height of object
    this._info.height := NumGet(&Info,offset,"Int")
    offset += 4
    ; BOOL accessibleComponent;               // flags for various additional
    ; skip use: accessibleInterfaces
    offset += 4
    ; BOOL accessibleAction;                  //  Java Accessibility interfaces
    ; skip use: accessibleInterfaces
    offset += 4
    ; BOOL accessibleSelection;               //  FALSE if this object doesn't
    ; skip use: accessibleInterfaces
    offset += 4
    ; BOOL accessibleText;                    //  implement the additional interface in question
    ; skip use: accessibleInterfaces
    offset += 4
    ; BOOL accessibleInterfaces;              // new bitfield containing additional interface flags
    accessibleInterfaces := NumGet(&Info,offset,"Int")

    this._info.accessibleValueInterface := (accessibleInterfaces & 1) == 1
    this._info.accessibleActionInterface := (accessibleInterfaces & 2) == 2
    this._info.accessibleComponentInterface := (accessibleInterfaces & 4) == 4
    this._info.accessibleSelectionInterface := (accessibleInterfaces & 8) == 8
    this._info.accessibleTableInterface := (accessibleInterfaces & 16) == 16
    this._info.accessibleTextInterface := (accessibleInterfaces & 32) == 32
    this._info.accessibleHypertextInterface := (accessibleInterfaces & 64) == 64

    RDA_Log_Debug(this._info.toString())

    return this._info
  }

  /*!
    Method: getTableInfo
      Retrieves table element info

    Throws:
      getAccessibleTableInfo failed

    Returns:
      <RDA_AutomationJABAccessibleTableInfo>
  */
  getTableInfo() {
    local
    global RDA_AutomationJABAccessibleTableInfo, RDA_AutomationJAB

    RDA_Log_Debug(A_ThisFunc)

    tableInfo := new RDA_AutomationJABAccessibleTableInfo()

    VarSetCapacity(Info, 40, 0)
    if (!DllCall(this.jab.dllName . "\getAccessibleTableInfo"
      , "Int", this.vmId, this.jab.acType, this.acId, "Ptr", &Info
      , "Cdecl " . this.jab.acType)) {
      throw RDA_Exception("getAccessibleTableInfo failed")
    }

    ; https://github.com/openjdk/jdk/blob/master/src/jdk.accessibility/windows/native/include/bridge/AccessBridgePackages.h#L651
    offset := 0

    ; JOBJECT64 caption;  // AccesibleContext
    tableInfo.caption := NumGet(&Info,offset,"Int64")
    offset += 8
    ;JOBJECT64 summary;  // AccessibleContext
    tableInfo.summary := NumGet(&Info,offset,"Int64")
    offset += 8
    ; jint rowCount;
    tableInfo.rowCount := NumGet(&Info,offset,"Int")
    offset += 4
    ; jint columnCount;
    tableInfo.columnCount := NumGet(&Info,offset,"Int")
    offset += 4
    ; JOBJECT64 accessibleContext;
    tableInfo.accessibleContext := NumGet(&Info,offset,"Int64")
    offset += 8
    ; JOBJECT64 accessibleTable;
    tableInfo.accessibleTable := NumGet(&Info,offset,"Int64")
    offset += 8

    ;RDA_Log_Debug(offset)
    RDA_Log_Debug(tableInfo.toString())

    return tableInfo
    /*
    row := 0
    column := 0

    VarSetCapacity(Info, 6188,0)
    if (!DllCall(this.jab.dllName . "\getAccessibleTableCellInfo"
      , "Int", this.vmId, this.jab.acType, tableInfo.accessibleTable, "Int", row, "Int", column, "Ptr", &Info
      , "Cdecl " . this.jab.acType)) {
      throw RDA_Exception("getAccessibleTableInfo failed")
    }
    ; https://github.com/wodenwang/nami/blob/master/package/src/main/package/java/win32/include/win32/bridge/AccessBridgePackages.h#L873
    offset := 0

    JOBJECT64  accessibleContext;
    jint     index;
    jint     row;
    jint     column;
    jint     rowExtent;
    jint     columnExtent;
    jboolean isSelected;
    */
  }
}



