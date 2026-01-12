/*!
  class: RDA_VirtualKey
    Virtual key
*/
class RDA_VirtualKey extends RDA_Base {
  /*!
    property: vk
      string - Virtual key, example: {vk41}
  */
  vk := ""
  /*!
    property: shift
      boolean - shift pressed?
  */
  shift := false
  /*!
    property: ctrl
      boolean - ctrl pressed?
  */
  ctrl := false
  /*!
    property: alt
      boolean - alt pressed?
  */
  alt := false
  /*!
    constructor: RDA_VirtualKey
      Creates a virtual key
  */
  __New(vk, shift, ctrl, alt) {
    this.vk := vk
    this.shift := shift
    this.ctrl := ctrl
    this.alt := alt
  }
  /*!
    Method: toString
      Retrieves the virtual key to be used with sendKeys
  */
  toString() {
    local
    output := ""

    if (this.shift) {
      output .= "{LShift Down}"
    }
    if (this.ctrl) {
      output .= "{LControl Down}"
    }
    if (this.alt) {
      output .= "{LAlt Down}"
    }

    output .= this.vk

    if (this.shift) {
      output .= "{LShift Up}"
    }
    if (this.ctrl) {
      output .= "{LControl Up}"
    }
    if (this.alt) {
      output .= "{LAlt Up}"
    }

    return output
  }
}
/*!
  class: RDA_AutomationKeyboard
    Keyboard handling at OS level.

  Remarks:
    type use Raw Mode
*/
class RDA_AutomationKeyboard extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationKeyboard)

  automation := 0

  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: type
      Sends given text (literally) as keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Remarks:
      use Raw mode: https://www.autohotkey.com/docs/v1/lib/Send.htm#Raw

    Parameters:
      text - string - Text
      hwnd - number - Window handle
      backgroundControl - string - Control parameter from ControlSend. See <RDA_KeyboardSendKeys>

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  type(text, hwnd := 0, backgroundControl := "") {
    RDA_Log_Debug(A_ThisFunc . "(text = " . text . ") " . ", " . hwnd . ", " . backgroundControl . ") ")

    RDA_KeyboardSendKeys(this.automation, hwnd, "{Raw}" . text, backgroundControl)

    return this
  }
  /*!
    Method: typePassword
      Sends given password (literally) as keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Remarks:
      use Raw mode: https://www.autohotkey.com/docs/v1/lib/Send.htm#Raw

    Parameters:
      text - string - Text
      hwnd - number - Window handle
      backgroundControl - string - Control parameter from ControlSend. See <RDA_KeyboardSendKeys>

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  typePassword(password, hwnd := 0, backgroundControl := "") {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ", " . hwnd . ", " . backgroundControl . ") ")

    RDA_KeyboardSendKeys(this.automation, hwnd, "{Raw}" . password, backgroundControl)

    return this
  }
  /*!
    Method: sendKeys
      Sends simulated keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Parameters:
      keys - string of keys
      hwnd - number - Window handle
      backgroundControl - string - Control parameter from ControlSend. See <RDA_KeyboardSendKeys>

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  sendKeys(keys, hwnd := 0, backgroundControl := "") {
    RDA_Log_Debug(A_ThisFunc . "(keys = " . keys . ", " . hwnd . ", " . backgroundControl . ") ")

    RDA_KeyboardSendKeys(this.automation, hwnd, keys, backgroundControl)

    return this
  }
  /*!
    Method: sendPassword
      It's an alias of <RDA_AutomationKeyboard.sendKeys> but just log the length

      See: <RDA_KeyboardSendKeys>

    Parameters:
      password - password string
      hwnd - number - Window handle
      backgroundControl - string - Control parameter from ControlSend. See <RDA_KeyboardSendKeys>

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  sendPassword(password, hwnd := 0, backgroundControl := "") {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ", " . hwnd . ", " . backgroundControl . ") ")

    RDA_KeyboardSendKeys(this.automation, hwnd, password, backgroundControl)

    return this
  }
  /*!
    Method: getKeyboardLayouts
      Retrieves selectable (by user) keyboard layouts

    Returns:
      number[]
  */
  getKeyboardLayouts() {
    local

    hkl_num := 20

    VarSetCapacity(hHkls, hkl_num * A_PtrSize, 0)
    num := DllCall("GetKeyboardLayoutList", "Uint", hkl_num, "Ptr", &hHkls)
    list := []

    loop,% num {
      list.push(NumGet(hHkls,(A_index-1)*A_PtrSize,"UPtr"))
    }

    VarSetCapacity(hHkls, 0)
    return list
  }

  /*!
    Method: letterToVirtualKey
      Retrieves virtual key config from given letter given in the given keyboard layout

    Parameters:
      letter - one letter string
      hkl - keyboard layout, see: <RDA_AutomationWindow.getKeyboardLayout>

    Throws:
      VkKeyScanExW call failed

    Returns:
      <RDA_VirtualKey>
  */
  letterToVirtualKey(letter, hkl) {
    local
    global RDA_VirtualKey

    RDA_Log_Debug(A_ThisFunc)

    retVK := DllCall("VkKeyScanExW","UShort",Asc(letter),"Ptr",hkl,"Short")

    if (retVK = -1)
      throw Exception("VkKeyScanExW call failed")

    vk := "0x" . SubStr(Format("{:x}", retVK & 0xFF), -2)

    ;vk := retVK & 0xFF
    shift := (retVK & 0x100) == 0x100
    ctrl := (retVK & 0x200) == 0x200
    alt := (retVK & 0x400) == 0x400
    vk := "{vk" . SubStr(vk, 3) . "}"

    ;return {"shift": shift, "ctrl": ctrl, "alt": alt, "vk": vk}
    return new RDA_VirtualKey(vk, shift, ctrl, alt)
  }
  /*!
    Method: textToVirtualKeys
      Retrieves virtual keys config from given text in the given keyboard layout

    Parameters:
      text - string - text
      hkl - keyboard layout, see: <RDA_AutomationWindow.getKeyboardLayout>

    Throws:
      VkKeyScanExW call failed

    Returns:
      <RDA_VirtualKey>[]
  */
  textToVirtualKeys(text, hkl) {
    local

    RDA_Log_Debug(A_ThisFunc)

    len := StrLen(text)
    list := []

    loop, % len {
      ch := SubStr(text, A_Index, 1)
      list.push(this.letterToVirtualKey(ch, hkl))
    }

    return list
  }
  /*!
    Method: textToSendKeys
      Retrieves a secuence of virtual keys (can be used in sendKeys) from given text in the given keyboard layout

    Parameters:
      text - string - text
      hkl - keyboard layout, see: <RDA_AutomationWindow.getKeyboardLayout>

    Throws:
      VkKeyScanExW call failed

    Returns:
      <RDA_VirtualKey>[]
  */
  textToSendKeys(text, hkl) {
    local

    RDA_Log_Debug(A_ThisFunc)

    output := ""

    keys := this.textToVirtualKeys(text, hkl)
    shift := false
    ctrl := false
    alt := false

    Loop, % keys.length() {
      k := keys[A_Index]

      ; start-stop modifiers
      if (shift && !k.shift) {
        output .= "{LShift Up}"
        shift := false
      }
      if (ctrl && !k.ctrl) {
        output .= "{LControl Up}"
        ctrl := false
      }
      if (alt && !k.alt) {
        output .= "{LAlt Up}"
        alt := false
      }

      if (!shift && k.shift) {
        output .= "{LShift Down}"
        shift := true
      }
      if (!ctrl && k.ctrl) {
        output .= "{LControl Down}"
        ctrl := true
      }
      if (!alt && k.alt) {
        output .= "{LAlt Down}"
        alt := true
      }

      output .= k.vk
    }
    ; close modifiers
    if (shift) {
      output .= "{LShift Up}"
    }
    if (ctrl) {
      output .= "{LControl Up}"
    }
    if (alt) {
      output .= "{LAlt Up}"
    }

    return output
  }

}
