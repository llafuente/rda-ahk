/*!
  Class: RDA_AutomationWindows
    Query OS for windows
*/
class RDA_AutomationWindows extends RDA_Base {
  /*!
    Constructor: RDA_AutomationWindows

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }

  /*!
    Method: get
      Retrieves all windows

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      automation := RDA_Automation()
      windows := automation.windows()
      wins := windows.get()
      ; print all windows!
      loop % wins.length() {
        msgbox % wins[A_Index].toString()
      }
      ==========================

    Parameters:
      hidden - boolean - Include hidden windows?

    Returns:
      <RDA_AutomationWindow[]>
  */
  get(hidden := false) {
    local r, windows, hwnd

    RDA_Log_Debug(A_ThisFunc . "(hidden? " . (hidden ? "yes" : "no") . ")")

    if (hidden == true) {
      DetectHiddenWindows On
    } else {
      DetectHiddenWindows Off
    }

    WinGet windows, List
    r := []
    Loop %windows%
    {
      hwnd := windows%A_Index%

      r.Push(new RDA_AutomationWindow(this.automation, hwnd))
    }

    return r
  }
  /*!
    Method: find
      Searches windows that match given object properties

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      automation := RDA_Automation()
      windows := automation.windows()
      win := windows.find({"title": "Notepad"})
      ; searches an application wich process name is notepad.exe
      win := windows.find({"process": "notepad.exe"})
      ; searches an application wich title start with Word (regex) and process name is word.exe
      win := windows.find({"$title": "Word.*", "process": "word.exe"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Returns:
      <RDA_AutomationWindow>[]
  */
  find(searchObject, hidden := false) {
    local wins, win, rwins := []

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ")")

    wins := this.get(hidden)

    loop % wins.Length() {
      win := wins[A_Index]
      if (win.isMatch(searchObject)) {
        rwins.push(win)
      }
    }

    RDA_Log_Debug(A_ThisFunc . " found " . rwins.length() . " windows")
    return rwins
  }

  /*!
    Method: findOne
      Searches for a single window that match given object properties

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      windows := automation.windows()
      Run notepad.exe
      sleep 3000 ; wait because it's a "find" example
      win := windows.findOne({process: "notepad.exe"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Throws:
      Window not found
      Multiple windows found

    Returns:
      <RDA_AutomationWindow>
  */
  findOne(searchObject, hidden := false) {
    local rwins
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ")")

    rwins := this.find(searchObject, hidden)
    if (!rwins.length()) {
      throw RDA_Exception("Window not found")
    }
    if (rwins.length() > 1) {
      throw RDA_Exception("Multiple windows found")
    }

    return rwins[1]
  }

  /*!
    Method: waitOne
      Waits for a single window

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?
      timeout - number - timeout, in miliseconds
      delay - number - delay, in miliseconds

      ======= AutoHotKey =======
      windows := RDA_Automation().windows()
      Run notepad.exe
      ; wait 30s to notepad to open
      win := windows.waitOne({process: "notepad.exe"}, false, 30000)
      ==========================

    Throws:
      Window not found
      Multiple windows found

    Returns:
      <RDA_AutomationWindow>
  */
  waitOne(searchObject, hidden := false, timeout := -1, delay := -1) {
    local bound
    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ", timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "findOne", searchObject, hidden)
    return RDA_RepeatWhileThrows(bound, timeout, delay)
  }

  /*!
    Method: findNew
      Searches windows that match given object properties that it's not in the given window list.

    Example:
      ======= AutoHotKey =======
      ; get previous windows
      automation := RDA_Automation()
      windows := automation.windows()
      previousWindows := windows.get()
      ; run your application
      Run notepad.exe
      Run notepad.exe

      sleep 2000 ; wait because it's a "find" example
      ; get your application
      notepadWins := windows.findNew({"process": "notepad.exe"}, previousWindows)
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      previousWindows - <RDA_AutomationWindow[]> - Black list, result of calling <RDA_AutomationWindows.get>
      hidden - boolean - search hidden windows?

    Returns:
      RDA_AutomationWindow[]
  */
  findNew(searchObject, previousWindows, hidden := false) {
    local rwins := [], wins, win, found
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no"))

    wins := this.get(hidden)
    loop % wins.Length() {
      win := wins[A_Index]

      ; skip previous windows
      found := false
      loop % previousWindows.Length() {
        if (win.hwnd == previousWindows[A_Index].hwnd) {
          found := true
          break
        }
      }
      if found {
        continue
      }

      if (win.isMatch(searchObject)) {
        rwins.push(win)
      }
    }

    return rwins
  }
  /*!
    Method: findOneNew
      Searches for a single window that match given object properties

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      windows := automation.windows()
      ; run notepad
      Run notepad.exe
      notepad1 := windows.waitOne({process: "notepad.exe"})

      ; run another notepad
      previousWindows := windows.get()
      Run notepad.exe
      sleep 10000 ; wait because it's a "find" example
      ; win will be the second one!
      win := windows.findOneNew({process: "notepad.exe"}, previousWindows)
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      previousWindows - <RDA_AutomationWindow>[] - Previous window state
      hidden - boolean - Search hidden windows?

    Throws:
      Window not found
      Multiple windows found

    Returns:
      <RDA_AutomationWindow>
  */
  findOneNew(searchObject, previousWindows, hidden := false) {
    local rwins
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no"))

    rwins := this.findNew(searchObject, previousWindows, hidden)
    if (!rwins.length()) {
      throw RDA_Exception("Window not found")
    }
    if (rwins.length() > 1) {
      throw RDA_Exception("Multiple windows found")
    }

    return rwins[1]
  }

  /*!
    Method: waitOneNew
      Waits for a single window

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      previousWindows - <RDA_AutomationWindow>[] - Previous window state
      hidden - boolean - Search hidden windows?
      timeout - number - timeout, in miliseconds
      delay - number - delay, in miliseconds

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      windows := automation.windows()
      previousWindows := windows.get()
      Run notepad.exe
      ; wait a new notepad to open
      win := windows.waitOneNew({process: "notepad.exe"}, previousWindows)
      ==========================

    Throws:
      Window not found
      Multiple windows found

    Returns:
      <RDA_AutomationWindow>
  */
  waitOneNew(searchObject, previousWindows, hidden := false, timeout := -1, delay := -1) {
    local bound
    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no") . ", timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "findOneNew", searchObject, previousWindows, hidden)
    return RDA_RepeatWhileThrows(bound, timeout, delay)
  }
}
