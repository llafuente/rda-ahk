/*!
  Class: RDA_AutomationWindows
*/
class RDA_AutomationWindows extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationWindows)

  /*!
    Constructor:

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(!automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }

  /*!
    Method: get
      Retrieves all windows

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
    Method: getWindow
      Searches windows that match given object properties

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      windows := RDA_Automation().windows()
      win := windows.find({title: "Notepad"})
      ; searches an application wich process name is notepad.exe
      win := windows.find({process: "notepad.exe"})
      ; searches an application wich title start with Word (regex) and process name is word.exe
      win := windows.find({$title: "Word.*", process: "word.exe"})
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
      windows := RDA_Automation().windows()
      Run notepad.exe
      sleep 30000 ; <-- this shall not be used
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
      windows := AutomationOS.getAllWindows(windows, title)
      ; run your application
      notepadPr := Process.runAsync("notepad.exe", Configuration.rootDir)

      sleep 2000
      ; get your application
      notepadWin := AutomationOS.getNewWindow(windows, "Notepad")
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      previousWindows - <AutomationWindow[]> - Black list, result of calling <AutomationOS.getAllWindows> before running your program
      hidden - boolean - search hidden windows?

    Returns:
      <AutomationWindow>[]
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
      windows := RDA_Automation().windows()
      ; run notepad
      Run notepad.exe
      sleep 10000
      ; run another notepad
      previousWindows := windows.get()
      Run notepad.exe
      sleep 10000
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
  waitOneNew(searchObject, previousWindows, hidden := false, timeout := -1, delay := -1) {
    local bound
    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no") . ", timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "findOneNew", searchObject, previousWindows, hidden)
    return RDA_RepeatWhileThrows(bound, timeout, delay)
  }
}
