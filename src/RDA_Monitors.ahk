; internal
RDA_EnumDisplayMonitors(hMonitor, HDC, PRECT, userdata) {
  local

  RDA_Log_Debug(A_ThisFunc . " = " . hMonitor)

  userdata := Object(userdata)
  if (userdata.info) {
    userdata.list.push(RDA_GetMonitorInfo(userdata.automation, hMonitor))
  } else {
    userdata.list.push(hMonitor)
  }

  Return true
}
; internal
RDA_GetMonitorInfo(automation, hMonitor) {
  local
  global RDA_ScreenRegion, RDA_Monitor

  ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-monitorinfoexw
  ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-monitorinfo
  MONITORINFOEX := 0
  size := 40 + (32 << !!A_IsUnicode)
  VarSetCapacity(MONITORINFOEX, size)
  NumPut(size, MONITORINFOEX, 0, "UInt")

  ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmonitorinfow
  if DllCall("User32.dll\GetMonitorInfoW"
      , "Ptr", hMonitor
      , "Ptr", &MONITORINFOEX
      , "Int") {
    return new RDA_Monitor(automation, StrGet(&MONITORINFOEX + 40, 32)
      , RDA_ScreenRegion.fromWin32Rect(automation, &MONITORINFOEX, 4)
      , RDA_ScreenRegion.fromWin32Rect(automation, &MONITORINFOEX, 20)
      , NumGet(MONITORINFOEX, 36, "UInt"))
  }
  throw RDA_Exception("GetMonitorInfoW failed with error: " . A_LastError)
}

/*!
  class: RDA_Monitors
    Represents a rectangle (w,h)
*/
class RDA_Monitors extends RDA_Base {
  automation := 0

  /*!
    constructor: RDA_Monitors
      Handle/Query monitors
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_Monitors{}"
  }
  ; internal
  _getMonitors(info) {
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaymonitors

    _RDA_EnumDisplayMonitors := RegisterCallback("RDA_EnumDisplayMonitors")
    userdata := {"list" : [], "automation": this.automation, info: info}
    if (!DllCall("User32.dll\EnumDisplayMonitors"
      , "Ptr", 0                        ; [in] HDC             hdc,
      , "Ptr", 0                        ; [in] LPCRECT         lprcClip,
      , "Ptr", _RDA_EnumDisplayMonitors ; [in] MONITORENUMPROC lpfnEnum,
      , "Ptr", &userdata                    ; [in] LPARAM          dwData
      , "Uint")) {
      throw RDA_Exception("EnumDisplayMonitors failed with error: " . A_LastError)
    }
    return userdata.list
  }
  /*!
    Method: count
      Retrieves how many monitors

    Returns:
      number - monitor count
  */
  count() {
    local

    RDA_Log_Debug(A_ThisFunc)
    list := this._getMonitors(true)

    RDA_Log_Debug(A_ThisFunc . " = " . list.length())
    return list.length()
  }
  /*!
    Method: get
      Retrieves all monitors

    Returns:
      <RDA_Monitor>[]
  */
  get() {
    local

    RDA_Log_Debug(A_ThisFunc)
    list := this._getMonitors(true)

    ; RDA_Log_Debug(list)

    return list
  }
  /*!
    Method: fromWindow
      Retrieves the display monitor that has the largest area of intersection with a specified window.

    Parameters:
      hwnd - number - window handle
      dwFlags - number -

        * MONITOR_DEFAULTTONULL    = 0 - Returns NULL.

        * MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.

        * MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the window.

    Returns:
      <RDA_Monitor>
  */
  fromWindow(hwnd, dwFlags := 0) {
    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", " . dwFlags . ")")
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-monitorfromwindow
    hMonitor := DllCall("User32.dll\MonitorFromWindow"
      , "Ptr", hwnd
      , "UInt", dwFlags
      , "Ptr")

    if (!hMonitor) {
      throw RDA_Exception("Could not found monitor")
    }

    monitor := RDA_GetMonitorInfo(this.automation, hMonitor)
    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", " . dwFlags . ") = " . monitor.name)

    return monitor
  }

  /*!
    Method: getPrimaryMonitor
      Retrieves the primary display monitor

    Returns:
      <RDA_Monitor>
  */
  getPrimaryMonitor() {
    local
    monitors := this.get()
    loop monitors.Length() {
      if (monitors[A_Index].primary) {
        return monitors[A_Index]
      }
    }
    throw RDA_Exception("Could not determine primary monitor")
  }
}

/*!
  class: RDA_Monitor
    OS monitor
*/
class RDA_Monitor {
  /*!
    Property: automation
  */
  automation := 0
  /*!
    Property: name
      string - name
  */
  name := 0
  /*!
    Property: display
      <RDA_ScreenRegion> - display area
  */
  display := 0
  /*!
    Property: work
      <RDA_ScreenRegion> - work area
  */
  work := 0
  /*!
    Property: primary
      bool - is primary ?
  */
  primary := 0
  /*!
    constructor: RDA_Monitor
      Handle/Query monitors
  */
  __New(automation, name, display, work, primary) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.name := name
    this.display := display
    this.work := work
    this.primary := primary
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_Monitor{name: " . this.name . ", primary: " . this.primary . ", display: " . this.display.toString() . ", work: " . this.work.toString() . "}"
  }
}
