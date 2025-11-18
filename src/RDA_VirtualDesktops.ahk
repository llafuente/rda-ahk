; https://github.com/mzomparelli/zVirtualDesktop/wiki
; https://github.com/MScholtes/VirtualDesktop/blob/master/VirtualDesktop.cs
; https://raw.githubusercontent.com/snaphat/virtual_desktop_enhancer/refs/heads/main/lib.ahk
; https://github.com/FuPeiJiang/VD.ahk
; https://github.com/search?q=language%3AAutoHotkey+_MoveViewToDesktop&type=code

/*!
  class: RDA_VirtualDesktop
    VirtualDesktop

  Remarks:
    Virtual desktop mess with many window funcionality like:

    * <RDA_AutomationWindow.getPosition>

    * <RDA_AutomationWindow.getSize>

    * <RDA_AutomationWindow.getRegion>

    Window need to be move/resize in the current virtual desktop
*/
class RDA_VirtualDesktop extends RDA_Base {
  /*!
    Property: index
      Virtual desktop index
  */
  index := 0
  /*!
    Constructor: RDA_VirtualDesktop
      VirtualDesktop

    Parameters:
      automation - <RDA_Automation> -
      index - number - 1 index
      ptr - pointer
  */
  __New(automation, index) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.index := index
  }

  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_VirtualDesktop{index: " . this.index . "}"
  }
}
/*!
  class: RDA_VirtualDesktops
    Virtual desktop manager
*/
class RDA_VirtualDesktops extends RDA_Base {
  automation := 0
  /*!
    constructor: RDA_VirtualDesktops

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }

  __Delete() {
  }
  /*!
    Method: count
      Retrieves virtual desktop count

    Returns:
      number - count
  */
  count() {
    global VD

    index := 0+VD.getCount()
    RDA_Log_Debug(A_ThisFunc " <-- " . index)

    return index
  }
  /*!
    Method: getCurrent
      Retrieves the current virtual desktop

    Returns:
      <RDA_VirtualDesktop>
  */
  getCurrent() {
    global VD, RDA_VirtualDesktop

    index := 0+VD.getCurrentDesktopNum()
    RDA_Log_Debug(A_ThisFunc " <-- " . index)

    return new RDA_VirtualDesktop(this.automation, index)
  }
  /*!
    Method: get
      Retrieves all virtual desktops

    Returns:
      <RDA_VirtualDesktop>[]
  */
  get() {
    local

    RDA_Log_Debug(A_ThisFunc . "()")
    list := this._get()
    RDA_Log_Debug(A_ThisFunc . "() Found " . list.length() . " desktops")

    return list
  }
  ; internal
  _get() {
    local
    global RDA_VirtualDesktop

    count := this.count()
    list := []
    loop % count {
      list.push(new RDA_VirtualDesktop(this.automation, A_Index))
    }

    return list
  }
  /*!
    Method: switchTo
      Moves view to given dektop

    Parameters:
      desktop - <RDA_VirtualDesktop> - desktop

    Returns:
      <RDA_VirtualDesktops> - for chaining
  */
  switchTo(desktop) {
    local
    global VD

    RDA_Log_Debug(A_ThisFunc . "(" . desktop.toString() . ")")

    VD.goToDesktopNum(desktop.index)

    return this
  }
  /*!
    Method: IsWindowOnCurrent
      Indicates whether the provided window is on the currently active virtual desktop.

    Parameters:
      hwnd_or_window - number | <RDA_AutomationWindow> - window or handle

    Returns:
      boolean
  */
  IsWindowOnCurrent(hwnd_or_window) {
    local
    global VD, RDA_AutomationWindow

    vdesktop := this.fromWindow(hwnd_or_window)

    return this.getCurrent().index == vdesktop.index
  }
  /*!
    Method: moveTo
      Moves a given window to the desktop indicated by index.

    Parameters:
      hwnd_or_window - number | <RDA_AutomationWindow> - window or handle
      desktop - <RDA_VirtualDesktop> - virtual desktop instance

    Returns:
      <RDA_VirtualDesktops> - for chaining
  */
  moveTo(hwnd_or_window, desktop) {
    local
    global VD, RDA_AutomationWindow

    hwnd := hwnd_or_window
    if (RDA_instaceOf(hwnd, RDA_AutomationWindow)) {
      hwnd := hwnd.hwnd
      RDA_Log_Debug(A_ThisFunc "(" . hwnd_or_window.toString() . ", " . desktop.toString() . ")")
    } else {
      RDA_Log_Debug(A_ThisFunc "(" . hwnd_or_window . ", " . desktop.toString() . ")")
    }

    ; Check window IDs (only attempt to move "valid" windows.)
    if (not this._IsValidWindow(hwnd)) {
      ; throw RDA_Exception("invalid window handle!")
      RDA_Log_Error("hwnd validation failed, " . A_ThisFunc . " may not work")
    }

    VD.MoveWindowToDesktopNum("ahk_id " . hwnd, desktop.index)

    return this
  }

  ; Fn to check if a window handle is valid.
  _IsValidWindow(hwnd) {
    if (hwnd == 0)
        return false ; not a valid ID.

    VarSetCapacity(cloaked,4, 0)
    DllCall("dwmapi\DwmGetWindowAttribute" , "Ptr", hwnd ,"UInt", 14, "Ptr", &cloaked, "UInt", 4)
    if (ErrorLevel) {
      line := A_LineNumber - 2
      RDA_Log_Error(A_ThisFunc . " Error: " . A_LastError)
      return false
    }

    val := NumGet(cloaked, "UInt") ; DWMWA_CLOAKED value.
    if (val != 0) { ; Needed for weeding out Windows10 Apps that are sleeping.
      return false ; Window is Cloaked.
    }

    WinGet, stat, MinMax, ahk_id %hwnd%
    if (stat == -1) {
      return false ; iconified so ignore.
    }

    WinGet, dwStyle, Style, ahk_id %hwnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
      return false ; no activate or not-visible.
    }

    WinGet, dwExStyle, ExStyle, ahk_id %hwnd%
    if (dwExStyle & 0x00000080) {
      return false ; Tool Window.
    }

    WinGetClass, szClass, ahk_id %hwnd%
    if ((szClass == "TApplication") || (szClass == "Windows.UI.Core.CoreWindow")) {
      return false ; Some delphi class window type.
    }

    WinGetTitle, title, ahk_id %hwnd%
    if not (title) {
      ; No title so not valid.
      return false
    }

    return true
  }

  /*!
    Method: fromWindow
      Retrieves the virtual desktop hosting the provided top-level window.

    Parameters:
      hwnd_or_window - number | <RDA_AutomationWindow> - window or handle

    Returns:
      <RDA_VirtualDesktop>
  */
  fromWindow(hwnd_or_window) {
    local
    global VD, RDA_VirtualDesktop, RDA_AutomationWindow

    hwnd := hwnd_or_window
    if (RDA_instaceOf(hwnd, RDA_AutomationWindow)) {
      hwnd := hwnd.hwnd
      RDA_Log_Debug(A_ThisFunc "(" . hwnd_or_window.toString() . ")")
    } else {
      RDA_Log_Debug(A_ThisFunc "(" . hwnd_or_window . ")")
    }

    index := VD.getDesktopNumOfWindow("ahk_id " . hwnd)
    RDA_Log_Debug(A_ThisFunc " <-- " . index)

    return new RDA_VirtualDesktop(this.automation, index)
  }


  ; backwards compat
  current() {
    return this.getCurrent()
  }
}

