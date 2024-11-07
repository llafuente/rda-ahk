/*!
  class: RDA_AutomationClipboard
    Clipboard handling at OS level
*/
class RDA_AutomationClipboard extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationClipboard)

  automation := 0

  __New(automation) {
    RDA_Assert(!automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: get
      Retrieves clipboard contents

    Returns
      string - clipboard contents
  */
  get() {
    local value := Clipboard
    RDA_Log_Debug(A_ThisFunc . " length = " . StrLen(value))
    return value
  }
  /*!
    Method: set
      Sets clipboard contents

    Parameters:
      value - string | Ptr -
      format - number - https://learn.microsoft.com/en-us/windows/win32/dataxchg/standard-clipboard-formats

        * 1: Text ( value = ascii string )

        * 13: Unicode text ( value = unicode string )

        * 2: bitmap ( value = HBITMAP)

    Throws:
      Could not perform operation
  */
  set(value, format := 1) {
    RDA_Log_Debug(A_ThisFunc . " length = " . StrLen(value) . ", format = " . format)

    if (format == 1) {
      Clipboard := value
      return
    }

    ; TODO test!
    if !DllCall("OpenClipboard", "Ptr", A_ScriptHwnd) {
      throw RDA_Exception("Could not perform operation")
    }

    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "UInt", 1, "Ptr", &this)
    hMem := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrLen(value) + 1, "Ptr")
    pMem := DllCall("GlobalLock", "Ptr", hMem, "Ptr")
    StrPut(this, pMem, "CP0")
    DllCall("GlobalUnlock", "Ptr", hMem)
    DllCall("SetClipboardData", "UInt", cf_rtf, "Ptr", hMem)
    DllCall("CloseClipboard")
  }

  ; TODO test!
  setRtf(value) {
    cf_rtf := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format")
    this.set(value, cf_rtf)
  }
  /*!
    Method: clear
      Tries to empty the clipboard

    Parameters:
      timeout - number - Timeout, in miliseconds
      delay - number - Delay, in miliseconds

    Throws:
      Timeout reached at RDA_AutomationClipboard.clear. Clipboard not empty.
  */
  clear(timeout := -1, delay := -1) {
    local startTime := A_TickCount
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_Log_Debug(A_ThisFunc . "(" . timeout . "," . delay . ")")

    ; force clear clipboard
    While (Clipboard != "") {
      if (A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
        throw RDA_Exception("Timeout reached at " . A_ThisFunc . ". Clipboard not empty.")
      }

      Clipboard := ""
      Sleep, % delay
    }
  }


  /*!
    Method: copy
      Copies selected "text" to clipboard

      It's just a shortcut of sending CTRL+C keys and wait the clipboard to be filled

    Remarks:
      It will clear clipboard before copy.

    Remarks:
      It will send input to the foreground window. It's recomemnded to use <RDA_AutomationWindow.copyToClipboard>

    Parameters:
      keys - string - Copy command by default CTRL+C
      timeout - number - timeout, in miliseconds
      delay - number - retry delay, in miliseconds

    Returns:
      Clipboard contents
  */
  copy(keys := "{Ctrl down}c{Ctrl up}", timeout := -1, delay := -1) {
    local startTime := A_TickCount, keyboard := this.automation.keyboard(), ret
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_Log_Debug(A_ThisFunc . "(" . keys . ", " timeout . ", " . delay . ")")

    this.clear(timeout, delay)

    ; copiar hasta que el portapapeles contenga algo
    while ((ret := Clipboard) == "") {
      if (A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
        throw RDA_Exception(A_ThisFunc . ": Timeout reached, clipboard still empty")
      }

      keyboard.sendKeys(keys)
      Sleep, % delay
    }

    return ret
  }
  /*!
    Method: wait
      Waits until the clipboard is filled

    Parameters:
      timeout - number - timeout, in seconds
      delay - number - check delay, in miliseconds

    Throws:
      Timeout reached, clipboard still empty

    Returns
      string - Clipboard contents
  */
  wait(timeout := -1, delay := -1) {
    local startTime := A_TickCount, value
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_Log_Debug(A_ThisFunc . "(" . timeout . ", " . delay . ")")

    while ((value := Clipboard) == "") {
      if (A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
        throw RDA_Exception(A_ThisFunc . ": Timeout reached, clipboard still empty")
      }
      Sleep, % delay
    }

    RDA_Log_Debug(A_ThisFunc . " length = " . StrLen(value))
    return value
  }
}
