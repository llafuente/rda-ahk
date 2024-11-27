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

    It's recommended to move the window to the origin before move.
*/
class RDA_VirtualDesktop extends RDA_Base {
  /*!
    Property: index
      Virtual desktop index
  */
  index := 0
  ; internal, this change with each execution but it's stable in the same execution
  ptr := 0
  /*!
    Constructor: RDA_VirtualDesktop
      VirtualDesktop

    Parameters:
      automation - <RDA_Automation> -
      index - number - 1 index
      ptr - pointer
  */
  __New(automation, index, ptr) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.index := index
    this.ptr := ptr
  }

  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_VirtualDesktop{index: " . this.index . ", ptr: " . this.ptr . "}"
  }
}
/*!
  class: RDA_VirtualDesktops
    Virtual desktop manager
*/
class RDA_VirtualDesktops extends RDA_Base {
  automation := 0
  iVirtualDesktopManager := 0
  iVirtualDesktopManagerInternal := 0
  /*!
    constructor: RDA_VirtualDesktops

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation

    CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" ;search VirtualDesktopManager clsid
    IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" ;search IID_IVirtualDesktopManager
    this.iVirtualDesktopManager := ComObjCreate(CLSID, IID)

    IServiceProvider                := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
    this.iVirtualDesktopManagerInternal  := ComObjQuery(IServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
    ObjRelease(IServiceProvider)

    ; TODO: CreateDesktopW                  := vtable(iVirtualDesktopManagerInternal, 10)
    ; TODO: RemoveDesktop                   := vtable(iVirtualDesktopManagerInternal, 11)
  }

  __Delete() {
    ObjRelease(this.iVirtualDesktopManager)
    ObjRelease(this.iVirtualDesktopManagerInternal)
  }
  /*!
    Method: count
      Retrieves virtual desktop count

    Returns:
      number - count
  */
  count() {
    GetCount := RDA_VTable(this.iVirtualDesktopManagerInternal, 3)

    desktopCount := 0
    DllCall(GetCount
      , "Ptr", this.iVirtualDesktopManagerInternal
      , "UInt*", desktopCount
      , "UInt")

    return 0+desktopCount
  }
  /*!
    Method: current
      Retrieves the current virtual desktop

    Returns:
      <RDA_VirtualDesktop>
  */
  current() {
    local

    RDA_Log_Debug(A_ThisFunc . "()")
    GetCurrentDesktop := RDA_VTable(this.iVirtualDesktopManagerInternal, 6)
    ptr := 0
    DllCall(GetCurrentDesktop
      , "UPtr", this.iVirtualDesktopManagerInternal
      , "UPtrP", ptr
      , "Uint")

    if ErrorLevel {
        throw RDA_Exception("GetCurrentDesktop failed")
    }

    return this._fromIVirtualDesktop(ptr)
  }

  _fromIVirtualDesktop(ptr) {
    local
    list := this._get()

    loop % list.length() {
      if (list[A_Index].ptr == ptr) {
        RDA_Log_Debug(A_ThisFunc . "() current desktop index = " . list[A_Index].index)
        return list[A_Index]
      }
    }

    throw RDA_Exception("Could not find IVirtualDesktop in the desktop list")
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

    GetDesktops := RDA_VTable(this.iVirtualDesktopManagerInternal, 7)

    IObjectArray := 0
    DllCall(GetDesktops
      , "UPtr", this.iVirtualDesktopManagerInternal
      , "UPtrP", IObjectArray
      , "UInt")
    if ErrorLevel {
        throw RDA_Exception(A_ThisFunc . ".GetDesktops failed")
    }
    GUID := ""
    VarSetCapacity(GUID, 16)
    DllCall("Ole32.dll\CLSIDFromString", "Str", "{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}", "UPtr", &GUID)
    if ErrorLevel {
        throw RDA_Exception(A_ThisFunc . ".CLSIDFromString failed")
    }
    ; IObjectArray::GetAt
    GetAt :=NumGet(NumGet(IObjectArray+0)+4*A_PtrSize)
    count := this.count()
    list := []
    loop % count {
      desktopPtr := 0
      DllCall(GetAt
        , "UPtr", IObjectArray
        , "UInt", A_Index-1
        , "UPtr", &GUID
        , "UPtrP", desktopPtr
        , "UInt")
      if ErrorLevel {
          line := A_LineNumber - 2
          MsgBox,,, Error in function '%A_ThisFunc%' on line %line%!`n`nError: '%A_LastError%'
      }
      list.push(new RDA_VirtualDesktop(this.automation, A_Index, desktopPtr + 0))
    }
    ObjRelease(IObjectArray) ; Clear comm object memory.
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
    RDA_Log_Debug(A_ThisFunc . "(" . desktop.toString() . ")")

    SwitchDesktop := RDA_VTable(this.iVirtualDesktopManagerInternal, 9)

    DllCall(SwitchDesktop
      , "Ptr", this.iVirtualDesktopManagerInternal
      , "Ptr", desktop.ptr
      , "UInt")

    return this
  }
  /*!
    Method: IsWindowOnCurrent
      Indicates whether the provided window is on the currently active virtual desktop.

    Parameters:
      hwnd - number - window handle

    Returns:
      boolean
  */
  IsWindowOnCurrent(hwnd) {
    local

    RDA_Log_Debug(A_ThisFunc "(" . hwnd . ")")

    IsWindowOnCurrentVirtualDesktop := NumGet(NumGet(this.iVirtualDesktopManager+0), 3*A_PtrSize)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx
    isOnCurrentDesktop := 0
    if(r := DllCall(IsWindowOnCurrentVirtualDesktop
        , "Ptr", this.iVirtualDesktopManager
        , "Ptr", hwnd
        , "IntP", isOnCurrentDesktop)) {
      throw RDA_Exception("IsWindowOnCurrentVirtualDesktop failed with error: " . r)
    }

    return isOnCurrentDesktop
  }
  /*!
    Method: moveTo
      Moves a given window to the desktop indicated by index.

    Parameters:
      hwnd - number - window handle
      desktop - <RDA_VirtualDesktop> - virtual desktop instance

    Returns:
      <RDA_VirtualDesktops> - for chaining
  */
  moveTo(hwnd, desktop) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", " . desktop.toString() . ")")

    ; Check window IDs (only attempt to move "valid" windows.)
    if (not this._IsValidWindow(hwnd)) {
      ; throw RDA_Exception("invalid window handle!")
      RDA_Log_Error("hwnd validation failed, " . A_ThisFunc . " may not work")
    }

    _ImmersiveShell                  := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
    _IApplicationViewCollection      := ComObjQuery(_ImmersiveShell,"{1841C6D7-4F9D-42C0-AF41-8747538F10E5}","{1841C6D7-4F9D-42C0-AF41-8747538F10E5}" )
    _GetViewForHwnd                  := RDA_VTable(_IApplicationViewCollection, 6)

    MoveViewToDesktop := RDA_VTable(this.iVirtualDesktopManagerInternal, 4)

    pView := 0
    r := DllCall(_GetViewForHwnd
      , "UPtr", _IApplicationViewCollection
      , "Ptr", hwnd
      , "Ptr*", pView
      , "UInt")
    RDA_Log_Debug(A_ThisFunc . "_GetViewForHwnd r = " . r . ", ErrorLevel = " . ErrorLevel . ")")
    RDA_Log_Debug("pView = " . pView)

    r := DllCall(MoveViewToDesktop
      , "Ptr", this.iVirtualDesktopManagerInternal
      , "Ptr", pView
      , "Ptr", 0 + desktop.ptr
      , "UInt")
    RDA_Log_Debug(A_ThisFunc . "MoveViewToDesktop r = " . r . ", ErrorLevel = " . ErrorLevel . ")")

    ObjRelease(_ImmersiveShell)
    ObjRelease(_IApplicationViewCollection)

    return this
  }

  ; Fn to check if a window handle is valid.
  _IsValidWindow(hwnd) {
      if (hwnd == 0)
          return False ; not a valid ID.

      VarSetCapacity(cloaked,4, 0)
      DllCall("dwmapi\DwmGetWindowAttribute" , "Ptr", hwnd ,"UInt", 14, "Ptr", &cloaked, "UInt", 4)
      if ErrorLevel {
          line := A_LineNumber - 2
          MsgBox,,, Error in function '%A_ThisFunc%' on line %line%!`n`nError: '%A_LastError%'
      }
      val := NumGet(cloaked, "UInt") ; DWMWA_CLOAKED value.
      if (val != 0) ; Needed for weeding out Windows10 Apps that are sleeping.
          return False ; Window is Cloaked.

      WinGet, stat, MinMax, ahk_id %hwnd%
      if (stat == -1)
          return False ; iconified so ignore.

      WinGet, dwStyle, Style, ahk_id %hwnd%
      if ((dwStyle&0x08000000) || !(dwStyle&0x10000000))
          return False ; no activate or not-visible.

      WinGet, dwExStyle, ExStyle, ahk_id %hwnd%
      if (dwExStyle & 0x00000080)
          return False ; Tool Window.

      WinGetClass, szClass, ahk_id %hwnd%
      if ((szClass == "TApplication") || (szClass == "Windows.UI.Core.CoreWindow"))
          return False ; Some delphi class window type.

      WinGetTitle, title, ahk_id %hwnd%
      if not (title) ; No title so not valid.
          return False
      return True
  }




  /*!
    Method: fromWindow
      Retrieves the virtual desktop hosting the provided top-level window.

    Parameters:
      hwnd - number - window handle

    Returns:
      <RDA_VirtualDesktop>
  */
  fromWindow(hwnd) {
    local

    RDA_Log_Debug(A_ThisFunc "(" . hwnd . ")")

    GetWindowDesktopId := NumGet(NumGet(this.iVirtualDesktopManager+0), 4*A_PtrSize)

    desktopId := ""
    VarSetCapacity(desktopID, 16, 0)

    ;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186441(v=vs.85).aspx
    if(r := DllCall(GetWindowDesktopId
      , "Ptr", this.iVirtualDesktopManager
      , "Ptr", hWnd
      , "Ptr", &desktopID)) {
      throw RDA_Exception("GetWindowDesktopId failed with error: " . r)
    }

    ptr := 0
    FindDesktop := RDA_VTable(this.iVirtualDesktopManagerInternal, 12)
    DllCall(FindDesktop
      , "Ptr", this.iVirtualDesktopManagerInternal
      , "Ptr", &desktopID
      , "Ptr*", ptr)

    return this._fromIVirtualDesktop(ptr)
  }

}

