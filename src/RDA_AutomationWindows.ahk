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
      automation := new RDA_Automation()
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
    local

    RDA_Log_Debug(A_ThisFunc . "(hidden? " . (hidden ? "yes" : "no") . ")")
    wins := this._get(hidden)
    RDA_Log_Debug(A_ThisFunc . "<-- found " . wins.length() . " windows")

    return wins
  }
  ; internal
  _get(hidden) {
    local
    global RDA_AutomationWindow

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
    Method: getJAB
      Retrieves all windows that have Java Access Bridge (JAB)

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      automation := new RDA_Automation()
      windows := automation.windows()
      wins := windows.getJAB()
      ==========================

    Returns:
      <RDA_AutomationWindow[]>
  */
  getJAB() {
    local
    RDA_Log_Debug(A_ThisFunc)
    jab := this.automation.jab
    wins := this.get()
    out := []
    loop % wins.length() {
      win := wins[A_Index]
      if (jab.isJavaWindow(win.hwnd)) {
        out.push(win)
      }
    }
    RDA_Log_Debug(A_ThisFunc . " found " . out.length() . " windows")
    return out
  }
  /*!
    Method: getForeground
      Retrieves a window instance to the foreground window
      (the window with which the user is currently working).

    Returns:
      <RDA_AutomationWindow>
  */
  getForeground() {
    local
    global RDA_AutomationWindow

    hwnd := RDA_GetForegroundWindow()
    RDA_Log_Debug(A_ThisFunc . " hwnd = " . hwnd)

    return new RDA_AutomationWindow(this.automation, hwnd)
  }
  /*!
    Method: find
      Searches windows that match given object properties

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      automation := new RDA_Automation()
      windows := automation.windows()
      ; retrieve all notepads by title
      win := windows.find({"title": "Notepad"})
      ; retrieve all notepads by process name
      win := windows.find({"process": "notepad.exe"})
      ; retrieve an application wich title start with Word (regex) and process name is word.exe
      win := windows.find({"$title": "Word.*", "process": "word.exe"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Returns:
      <RDA_AutomationWindow>[]
  */
  find(searchObject, hidden := false) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ")")

    wins := this._find(searchObject, hidden)

    RDA_Log_Debug(A_ThisFunc . " found " . wins.length() . " windows")

    return wins
  }
  ; internal
  _find(searchObject, hidden := false) {
    local

    rwins := []
    wins := this._get(hidden)

    loop % wins.Length() {
      win := wins[A_Index]
      if (win.isMatch(searchObject)) {
        rwins.push(win)
      }
    }

    return rwins
  }

  /*!
    Method: findOne
      Searches for a single window that match given object properties

    Example:
      ======= AutoHotKey =======
      automation := new RDA_Automation()
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

    rwins := this._find(searchObject, hidden)
    if (!rwins.length()) {
      throw RDA_Exception("Window not found")
    }
    if (rwins.length() > 1) {
      throw RDA_Exception("Multiple windows found")
    }

    RDA_Log_Debug(A_ThisFunc . " <-- " . rwins[1].toString())
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
      windows := (new RDA_Automation()).windows()
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
    local
    global RDA_Automation

    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ", timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "findOne", searchObject, hidden)
    win := RDA_RepeatWhileThrows(bound, timeout, delay, true)

    RDA_Log_Debug(A_ThisFunc . " <-- " . win.toString())

    return win
  }
  /*!
    Method: waitOneOf
      Returns the first window that match before timeout

    Example:
      ======= AutoHotKey =======
      ; searches an application wich title Notepad
      automation := new RDA_Automation()
      windows := automation.windows()
      win := windows.waitOneOf([{"title": "Error dialog"}, {"title": "App frame"}])
      switch(win.title) {
        case "Error dialog":
          throw RDA_Exception("Error dialog found")
        case "App frame":
          ; ...
      }
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch>[] - search objects
      hidden - boolean - Search hidden windows?

    Returns:
      <RDA_AutomationWindow> - First window found
  */
  waitOneOf(searchObjects, hidden := false, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObjects) . ", hidden? " . (hidden ? "yes" : "no") . ", " . timeout . ", " . delay . ")")

    startTime := A_TickCount

    loop {
      wins := this.get(hidden)

      loop % wins.Length() {
        win := wins[A_Index]
        loop % searchObjects.length() {
          searchObject := searchObjects[A_Index]
          if (win.isMatch(searchObject)) {
            return win
          }
        }
      }

      if (timeout <= 0 || A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
        throw RDA_Exception("Window(s) not found")
      }

      sleep % delay
    }
  }

  /*!
    Method: getNew
      Retreves all new windows

    Example:
      ======= AutoHotKey =======
      ; get previous windows
      automation := new RDA_Automation()
      windows := automation.windows()
      previousWindows := windows.get()
      ; run your application
      Run notepad.exe
      Run mspaint.exe

      sleep 2000 ; wait because it's a "find" example
      ; get your application
      notepadWins := windows.getNew(previousWindows)
      ==========================

    Parameters:
      previousWindows - <RDA_AutomationWindow[]> - Black list, result of calling <RDA_AutomationWindows.get>
      hidden - boolean - search hidden windows?

    Returns:
      RDA_AutomationWindow[]
  */
  getNew(previousWindows, hidden := false) {
    local
    RDA_Log_Debug(A_ThisFunc . "(previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no"))

    output := []
    wins := this._get(hidden)
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

      output.push(win)
    }

    RDA_Log_Debug(A_ThisFunc . "<-- found " . wins.length() . " windows")

    return output
  }

  /*!
    Method: findNew
      Searches windows that match given object properties that it's not in the given window list.

    Example:
      ======= AutoHotKey =======
      ; get previous windows
      automation := new RDA_Automation()
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
    local
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no"))

    output := []
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
        output.push(win)
      }
    }

    return output
  }
  /*!
    Method: findOneNew
      Searches for a single window that match given object properties

    Example:
      ======= AutoHotKey =======
      automation := new RDA_Automation()
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
    local
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no"))

    output := this.findNew(searchObject, previousWindows, hidden)
    if (!output.length()) {
      throw RDA_Exception("Window not found")
    }
    if (output.length() > 1) {
      throw RDA_Exception("Multiple windows found")
    }

    return output[1]
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
      automation := new RDA_Automation()
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
    local
    global RDA_Automation

    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . " , previousWindows.length = " . previousWindows.length() . ", hidden? " . (hidden ? "yes" : "no") . ", timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "findOneNew", searchObject, previousWindows, hidden)
    win := RDA_RepeatWhileThrows(bound, timeout, delay, true)

    RDA_Log_Debug(A_ThisFunc . " <-- " . win.toString())

    return win
  }

;  expectOneVisible(searchObject, timeout, delay, exceptionError)
}
