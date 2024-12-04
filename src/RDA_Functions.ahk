/*!
  Function: RDA_JSON_stringify
    Encodes to json string given object

  Parameters:
    obj - any - object to encode
    replacer - Func -
    space - string|number - space char or count

  Returns:
    string
*/
RDA_JSON_stringify(obj, replacer:="", space:="") {
  global JSON

  return JSON.dump(obj, replacer, space)
}

/*!
  Function: RDA_JSON_parse
    Decodes given json string

  Parameters:
    jsonStr - any - object to encode
    reciever - Func -

  Returns:
    object
*/
RDA_JSON_parse(jsonStr, reciever := "") {
  global JSON

  return JSON.load(jsonStr, reciever)
}

/*!
  Function: RDA_VTable
    Retrieves the pointer to a vtable element

  Parameters:
    p - pointer
    n - number - offset

  Returns:
    pointer
*/
RDA_VTable(p, n) {
  local
  return NumGet(NumGet(p+0,"ptr")+n*A_PtrSize,"ptr")
}

/*!
  Function: RDA_Array_IndexOf
    Returns the first index at which a given element can be found in the array, or -1 if it is not present

    The contents of the arrays must be primitives as *==* will be used to compare.

  Parameters:
    arr - any[] - array
    avalue - any - Value
    fromIndex - number - Starting index

  Returns:
    number - 1 index if found, 0 otherwise
*/
RDA_Array_IndexOf(arr, avalue, fromIndex := 1) {
  local index, value
  for index, value in arr {
    if (index < fromIndex) {
      Continue
    }

    if (value == avalue) {
      return index
    }
  }

  return 0
}

/*!
  Function: RDA_Array_Concat
    Creates a new array with the concatenation of the sent ones

  Example:
    ======= AutoHotKey =======
    arr := [1, 2, 3]
    arr := [3, 4, 5]

    arr3 := RDA_Array_Concat(arr, arr2) ; [1, 2, 3, 3, 4, 5]
    ==========================

  Parameters:
    arr - any[] - Array of things
    obj - any[] - Array of things

  Returns:
    any[] - Concatenated array of things
*/
RDA_Array_Concat(arr, arr2) {
  local out
  out := []
  loop % arr.Length() {
    out.push(arr[A_Index])
  }
  loop % arr2.Length() {
    out.push(arr2[A_Index])
  }
  return out
}

/*!
  Function: RDA_Array_Join
    Creates and returns a new string by concatenating all of the elements in an array
    separated by commas or a specified separator string

  Parameters:
    arr - object[] - array
    separator - string - separator

  Returns:
    string
*/
RDA_Array_Join(arr, separator := ",") {
  local out, k, v
  out := ""
  for k, v in arr {
    out .= separator . v
  }

  return SubStr(out, 1 + StrLen(separator))
}

/*!
  Function: RDA_IsArray
    Try to guess if the argument is a dense array.

  Remarks:
      ======= AutoHotKey =======
        RDA_IsArray({}) ; True - An empty Object it's an array.
        RDA_IsArray({1:1, 2:2, 3:3}) ; True - Looks like an array!
        RDA_IsArray({1:1, 2:2, 3:3, x: 0}) ; False
        RDA_IsArray({1:1, 2:2, 4:3}) ; False, not dense
        x := {}
        x.push(1)
        RDA_IsArray(x) ; True
      ==========================

  Parameters:
    anything - any - anything you want to test

  Returns:
    boolean - is array?
*/
RDA_IsArray(anything) {
  ; empty object/array check
  if (IsObject(anything) && !ObjCount(anything)) {
    return true
  }
  ; dense array check
  if ((IsObject(anything) && ObjMinIndex(anything) == 1 && ObjMaxIndex(anything) == ObjCount(anything))) {
    return true
  }
  return false
  ;anything.maxIndex() > 0
  ;return  ||
  ; this method proposed by lexicos exclude empty array
  ; I rather prefer to false negative empty object
  ; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=64332
  ;return !ObjCount(arrOrObj) || ObjMinIndex(arrOrObj) == 1 && ObjMaxIndex(arrOrObj) == ObjCount(arrOrObj) && arrOrObj.Clone().Delete(1, arrOrObj.MaxIndex()) == ObjCount(arrOrObj)
}

/*!
  Function: RDA_Exception
    Generates an exception and log the stack trace.

  Parameters:
    message - string - Exception message
    trace_offset - number - Trace offset
    What - any - User data
*/
RDA_Exception(message, trace_offset := 0, What := "") {
  local
  RDA_Log_Debug(A_ThisFunc . " " . message)
  ; traceback to log
  r := [], i := 0, n := (A_AhkVersion<"2" ? 2 : 3) + trace_offset
  Loop {
    e := Exception(".", offset := -(A_Index + n))
    if (e.What == offset) {
      RDA_Log_Debug(e.file ":" e.Line " @ main")
      break
    }
    RDA_Log_Debug(e.file ":" e.Line " @ " e.What)
  }

  return Exception(message, trace_offset - 1, What)
}

/*!
  Function: RDA_Assert
    Asserts (throw RDA_Exception) if given expression is false

  Parameters:
    expr - any - value
    message - string - Exception message

  Throws:
    given message
*/
RDA_Assert(expr, message) {
  if (!expr) {
    throw RDA_Exception(message)
  }
}

/*!
  Function: RDA_RepeatWhileThrows
    Call given function until no throws or timeout is reached

  Parameters:
    fn - Func | FuncBound - Function
    timeout - timeout in miliseconds
    delay - number - Time between retries, in miliseconds

  Throws:
    any exception thrown by fn

  Returns:
    any - Result from the given function
*/
RDA_RepeatWhileThrows(fn, timeout, delay) {
  local lastException, startTime, e, r

  lastException := 0
  startTime := A_TickCount

  RDA_Log_Debug(A_ThisFunc . " call """ . fn.Name . """ timeout = " . timeout . " delay = " . delay)
  loop
  {
    try {
      r := fn.Call()
      return r
    } catch e {
      lastException := e
    }

    if (timeout <= 0 || A_TickCount >= startTime + timeout) {
      RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
      throw lastException
    }

    sleep % delay
  }
}



/*!
  Function: RDA_Window_WaitClose
    Waits window to be closed

  Parameters:
    hwnd - number - windows identifier
    timeout - number - Timeout, in miliseconds

  Returns:
    boolean - If the window exists after waiting to close
*/
RDA_Window_WaitClose(hwnd, timeout) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", timeout = " . timeout . ")")

  timeout /= 1000
  WinWaitClose ahk_id %hwnd%, 0, %timeout%

  return RDA_Window_Exist(hwnd)
}

/*!
  Function: RDA_Window_Close
    Closes the specified window and wait until the specified window does not exist.

  Parameters:
    hwnd - number - window identifier
    timeout - number - timeout, in miliseconds
              timeout <= 0, then it won't wait and return false

  Returns:
    boolean - If the window exists after waiting to close
*/
RDA_Window_Close(hwnd, timeout) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", timeout = " . timeout . ")")
  WinClose ahk_id %hwnd%

  if (timeout > 0) {
    return RDA_Window_WaitClose(hwnd, timeout)
  }

  return false
}
/*!
  Function: RDA_Window_Exist
    Checks if the specified window exists.

  Parameters:
    hwnd - number - windows identifier.

  Remarks:
    DO NOT SEND a win32 controls handle

  Returns:
    boolean - If the window exists after waiting to close
*/
RDA_Window_Exist(hwnd) {
  local result

  result := (WinExist("ahk_id " . hwnd) != 0)

  RDA_Log_Debug(A_ThisFunc . " hwnd = " . hwnd . " result = " . (result ? "yes" : "no"))
  return result
}

/*!
  Function: RDA_Window_Move
    Changes the position of the specified window.

  Parameters:
    hwnd - number - window identifier
    x - number - x screen coordinate
    y - number - y screen coordinate
*/
RDA_Window_Move(hwnd, x, y) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", " . x . ", " . y . ")")

  ; https://www.autohotkey.com/docs/v1/lib/WinMove.htm
  WinMove, ahk_id %hwnd%,, % x, % y
}

/*!
  Function: RDA_Window_Resize
    Resizes the specified window.

  Parameters:
    hwnd - number - window identifier
    w - number - Width
    h - number - Height
*/
RDA_Window_Resize(hwnd, w, h) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ", " . w . ", " . h . ")")

  WinMove, ahk_id %hwnd%,,,, %w%, %h%
}

/*!
  Function: RDA_Window_GetSizeAndPosition
    Get control/window screen position, height and width

  Parameters:
    automation - <RDA_Automation>
    hwnd - number - Control/window identifier

  Returns:
    <RDA_ScreenRegion>
*/
RDA_Window_GetSizeAndPosition(automation, hwnd) {
  local winX, winY, winW, winH, region

  WinGetPos, winX, winY, winW, winH, ahk_id %hwnd%

  region := new RDA_ScreenRegion(new RDA_ScreenPosition(automation, winX ? winX : 0, winY ? winY : 0), new RDA_Rectangle(automation, winW ? winW : 0, winH ? winH : 0))
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ") = " . region.toString())

  return region
}
/*!
  Function: RDA_BlockInput
    Wrapper for BlockInput

  Remarks:
    It may require admin priviledges!

  Parameters:
    value - On|Off
*/
RDA_BlockInput(value) {
  BlockInput % value
}

/*!
  Function: RDA_Mouse_ScreenClick
    Perform a click into given coords

  Remarks:
    Asume interactive mode regardless automation configuration sent.

  Remarks:
    Use [Click](https://www.autohotkey.com/docs/commands/Click.htm)

  Parameters:
    automation - <RDA_Automation>
    button - string - LEFT|RIGHT|MIDDLE|X1|X2
    clickCount - number - The number of times to click the mouse
    x - number - screen x position, 9999 means that the mouse will not move
    y - number - screen y position, 9999 means that the mouse will not move
*/
RDA_Mouse_ScreenClick(automation, button, clickCount, x := 9999, y := 9999) {
  local

  RDA_Log_Debug(A_ThisFunc . "(button = " . button . ", clickCount = " . clickCount . ", " . x . ", " . y . ") " . automation.toString())

  SetMouseDelay % automation.mouseDelay
  SendMode % automation.sendMode

  if (x != 9999 && y != 9999) {
    RDA_MouseMove(automation, 0, x, y)
  }

  automation.requestBlockInput(false)
  ; click has no ErrorLevel/exceptions -> no try
  Click %button%, %clickCount%
  automation.releaseBlockInput(false)

  sleep % automation.actionDelay
}
/*!
  Function: RDA_Mouse_WindowClick
    Perform a click into given windows relative position.

    If x,y are sent it will move the mouse first, then click

  Remarks:
    * *interactive*:

      * Activate window

      * Mouse move if x,y non default

      * [Click](https://www.autohotkey.com/docs/commands/Click.htm) (It does not use MouseClick because user can swap Left/Right)

    * *background*:

      * PostMessage: WM_MOUSEMOVE

      * [ControlClick](https://www.autohotkey.com/docs/commands/ControlClick.htm), if x,y is default it will click at the center

  Parameters:
    automation - <RDA_Automation>
    hwnd - number - window handle
    button - string - LEFT|RIGHT|MIDDLE|X1|X2
    clickCount - number - The number of times to click the mouse
    x - number - screen x position, 9999 means that the mouse will not move
    y - number - screen y position, 9999 means that the mouse will not move

  Throws:
    background mode require hwnd
*/
RDA_Mouse_WindowClick(automation, hwnd, button, clickCount, x := 9999, y := 9999) {
  local

  options := "NA"
  if (x != 9999) {
    options .= " x" . x
  }
  if (x != 9999) {
    options .= " y" . y
  }

  RDA_Log_Debug(A_ThisFunc . "(hwnd = " . hwnd . ", button = " . button . ", clickCount = " . clickCount . ", " . options . ") " . automation.toString())

  SetMouseDelay % automation.mouseDelay
  SendMode % automation.sendMode

  if (automation.inputMode == "interactive") {
    if (x != 9999 && y != 9999) {
      winPos := RDA_Window_GetSizeAndPosition(automation, hwnd).origin

      RDA_MouseMove(automation, hwnd, winPos.x + x, winPos.y + y)
    }

    automation.requestBlockInput()
    ; click has no ErrorLevel/exceptions -> no try
    Click %button%, %clickCount%
    automation.releaseBlockInput()

  } else {
    if (!hwnd) {
      throw RDA_Exception("background mode require hwnd")
    }
    ; mimic mouse move event
    PostMessage, 0x200, 0, % (x & 0xFFFF)|(y << 16), , % "ahk_id " hwnd ;WM_MOUSEMOVE := 0x200

    ;PostMessage, 0x201, 0, % (x & 0xFFFF)|(y<<16),, % "ahk_id " hWnd ;WM_LBUTTONDOWN := 0x201
    ;PostMessage, 0x202, 0, % (x & 0xFFFF)|(y<<16),, % "ahk_id " hWnd ;WM_LBUTTONUP := 0x202

    sleep 250 ; give some time the app to "hover"

    automation.requestBlockInput()
    try {
      ControlClick, , ahk_id %hwnd%,, %button%, %clickCount%, %options%
    } catch e {
      err := e
    } finally {
      automation.releaseBlockInput()
    }

    if (err) {
      RDA_Log_Error(A_ThisFunc . " ControlClick failed: " . e.message)
      throw RDA_Exception("Control click failed with error: " . e.message)
    }
  }

  sleep % automation.actionDelay
}

/*!
  Function: RDA_MouseMove
    Moves the mouse cursor.to given screen position

  Remarks:
    There is no mouse move in *background* mode.

  Parameters:
    automation - <RDA_Automation>
    hwnd - number - window handle
    x - number - x screen coordinate
    y - number - y screen coordinate
*/
RDA_MouseMove(automation, hwnd, x, y) {
  RDA_Log_Debug(A_ThisFunc . "(x = " . x . " , y = " . y . ") " . automation.toString())

  if (automation.inputMode == "interactive" and hwnd) {
    RDA_Window_Activate(hwnd, RDA_Automation.TIMEOUT, RDA_Automation.DELAY)
  }

  SetMouseDelay % automation.mouseDelay
  SendMode % automation.sendMode
  CoordMode Mouse, Screen

  automation.requestBlockInput(false)
  ; MouseMove has no ErrorLevel/exceptions -> no try
  MouseMove, % x, % y, % automation.mouseSpeed
  automation.releaseBlockInput(false)

  sleep % automation.actionDelay
}

/*!
  Function: RDA_MouseRelativeMove
    Moves the mouse cursor to a position relative to given window

  Parameters:
    automation - <RDA_Automation>
    hwnd - number - window identifier, 0 means relative to current position
    x - number - x coordinate
    y - number - y coordinate
*/
RDA_MouseRelativeMove(automation, x, y) {
  RDA_Log_Debug(A_ThisFunc . "(x = " . x . " , y = " . y . ") " . automation.toString())

  SetMouseDelay % automation.mouseDelay
  SendMode % automation.sendMode
  CoordMode Mouse, Screen

  automation.requestBlockInput(false)
  ; MouseMove has no ErrorLevel/exceptions -> no try
  MouseMove, % x, % y, % automation.mouseSpeed, R
  automation.releaseBlockInput(false)

  sleep % automation.actionDelay
}

/*!
  Function: RDA_MouseGetPosition
    Retrieves the current position of the mouse cursor

  Parameters:
    automation - <RDA_Automation>

  Returns:
    <RDA_ScreenPosition>
*/
RDA_MouseGetPosition(automation) {
  local
  global RDA_ScreenPosition

  MouseGetPos x, y
  p := new RDA_ScreenPosition(automation, x, y)

  RDA_Log_Debug(A_ThisFunc . " " . p.toString())

  return p
}

/*!
  Function: RDA_Window_Opaque
    Disables windows transparency

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Opaque(hwnd) {
  local e
  try {
    WinSet, Transparent, Off, ahk_id %hwnd%
  } catch e {
    RDA_Log_Error(A_ThisFunc . " " . e.message)
  }
}

/*!
  Function: RDA_Window_Transparent
    Enables windows transparency

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Transparent(hwnd) {
  local e
  try {
    WinSet, Transparent, On, ahk_id %hwnd%
  } catch e {
    RDA_Log_Error(A_ThisFunc . " " . e.message)
  }
}

/*!
  Function: RDA_Window_Hide
    Hides the window.

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Hide(hwnd) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")
  WinHide ahk_id %hwnd%
}
/*!
  Function: RDA_Window_Show
    Shows the window.

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Show(hwnd) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")
  WinShow ahk_id %hwnd%
}

/*!
  Function: RDA_Window_Activate
    Activates the specified window that hwnd belong aka bring to front

  Remarks:
    It makes sure the active window is the send one.
    It will try again if fail.

  Remarks:
    It may fail if the hwnd sent is not a window one.

  Parameters:
    hwnd - number - window identifier
    timeout - number - timeout, in miliseconds
    delay - number - delay, in miliseconds
*/
RDA_Window_Activate(hwnd, timeout, delay) {
  local v, winHwnd, hwnd2, startTime

  winHwnd := DllCall("user32\GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr") ;GA_ROOT := 2
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . " / " . winHwnd . ")")

  ; be gentle, WinActivate can halt the process inside a RDP
  ; but also forcefull ^.^ because SendKeys fail if we fail
  startTime := A_TickCount

  loop {
    ; hwnd2 := WinExist("A")
    hwnd2 := DllCall("GetForegroundWindow")

    if (hwnd2 == winHwnd) {
      return
    }

    RDA_Log_Debug(A_ThisFunc . " GetForegroundWindow = " . hwnd2)
    WinActivate ahk_id %winHwnd%

    if (A_TickCount >= startTime + timeout) {
      RDA_Log_Error(A_ThisFunc . " timeout reached")
      throw RDA_Exception("Timeout reached")
    }

    sleep % delay
  }
}

/*!
  Function: RDA_KeyboardSendKeys
    Sends simulated keystrokes

  Remarks:
    * *interactive*: Activates window (if sent) and then use [Send](https://www.autohotkey.com/docs/commands/Send.htm)
    * *background*: Use [ControlSend](https://www.autohotkey.com/docs/commands/ControlSend.htm)

  Parameters:
    automation - <RDA_Automation>
    hwnd - control/window identifier (optional)
    password - password string
    control - string - Control parameter from ControlSend.
      Values:

        * blank: The target window's topmost control will be used

        * ahk_parent: The keystrokes will be sent directly to the target window

        * ClassNN: The keystrokes will be send directly to the control

        * control text: The keystrokes will be send directly to the control

  Throws:
    hwnd is required in background input mode
*/
RDA_KeyboardSendKeys(automation, hwnd, keys, control) {
  local
  global RDA_Automation
  RDA_Log_Debug(A_ThisFunc . "(hwnd = " . hwnd . ", keys.length = " . StrLen(keys) . ", control = " . control . ") " . automation.toString())

  ; we do not honor Play mode
  DetectHiddenWindows, On
  SetKeyDelay % automation.keyDelay, % automation.pressDuration
  SendMode % automation.sendMode

  if (automation.inputMode == "interactive") {
    ; block input at this moment so user can't interference
    if (hwnd) {
      RDA_Window_Activate(hwnd, RDA_Automation.TIMEOUT, RDA_Automation.DELAY)
    }

    automation.requestBlockInput()
    ; Send has no ErrorLevel/exceptions -> no try
    Send, %keys%
    automation.releaseBlockInput()

  } else {
    if (!hwnd) {
      throw RDA_Exception("hwnd is required in background input mode")
    }
    ; this doesn't work on every process, but it's the preferable mode
    SetBatchLines -1
    SetTitleMatchMode 2

    ; log error but don't stop
    try {
      PostMessage, 0x0006, 1, 0, , ahk_id %hwnd% ; WM_ACTIVATE := 0x0006
      sleep 250
    } catch e {
      if (e.message == 1) {
        RDA_Log_Error(A_ThisFunc . " PostMessage - activate failed (probably hwnd don't exist)")
      }
    }

    automation.requestBlockInput()
    err := 0
    try {
      ControlSend, %control%, %keys%, ahk_id %hwnd%
    } catch e {
      err := e
    } finally {
      automation.releaseBlockInput()
    }
    if (err) {
      if (err.message == 1) {
        throw RDA_Exception("ControlSend failed (probably hwnd don't exist)")
      }
      ; unreachable? but how knows.
      throw err
    }


    ; log error but don't stop
    try {
      PostMessage, 0x0006, 0, 0, , ahk_id %hwnd% ; WM_ACTIVATE := 0x0006
    } catch e {
      if (e.message == 1) {
        RDA_Log_Error(A_ThisFunc . " PostMessage - deactivate failed (probably hwnd don't exist)")
      }
    }
  }

  sleep % automation.actionDelay
}
/*!
  Function: RDA_Window_Minimize
    Collapses the specified window into a button on the task bar.

  Remarks:
    https://www.autohotkey.com/docs/commands/WinMinimize.htm

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Minimize(hwnd) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinMinimize, ahk_id %hwnd%
}

/*!
  Function: RDA_Window_Restore
    Unminimizes or unmaximizes the specified window if it is minimized or maximized.

  Remarks:
    https://www.autohotkey.com/docs/commands/WinRestore.htm

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Restore(hwnd) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinRestore, ahk_id %hwnd%
}
/*!
  Function: RDA_Window_Maximize
    Enlarges the specified window to its maximum size.

  Remarks:
    https://www.autohotkey.com/docs/commands/WinMaximize.htm

  Parameters:
    hwnd - number - window identifier
*/
RDA_Window_Maximize(hwnd) {
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinMaximize, ahk_id %hwnd%
}

/*!
  Function: RDA_Window_IsMinimized
    Returns if the window is minimized

  Parameters:
    hwnd - number - window identifier

  Returns
    boolean - Is minimized
*/
RDA_Window_IsMinimized(hwnd) {
  local v
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinGet, v, MinMax, ahk_id %hwnd%
  return v == -1
}
/*!
  Function: RDA_Window_IsMaximized
    Returns if the window is maximized

  Parameters:
    hwnd - number - window identifier

  Returns
    boolean - Is maximized
*/
RDA_Window_IsMaximized(hwnd) {
  local v
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinGet, v, MinMax, ahk_id %hwnd%

  return v == 1
}

/*!
  Function: RDA_Window_IsRestored
    Returns if the window is restored

  Parameters:
    hwnd - number - window identifier

  Returns
    boolean - Is restored
*/
RDA_Window_IsRestored(hwnd) {
  local v
  RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")

  WinGet, v, MinMax, ahk_id %hwnd%

  return v == 0
}
/*!
  Function: RDA_PixelGetColor
    Retrieves the color of the pixel at the specified X and Y coordinates.

  Remarks:
    https://www.autohotkey.com/docs/v1/lib/PixelGetColor.htm

  Returns
    number - RGB Color
*/
RDA_PixelGetColor(x, y) {
  CoordMode Pixel
  CoordMode, Mouse, Screen
  PixelGetColor, c, %x%, %y%, RGB

  RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ") = " . c)
  return c
}

/*!
  Function: RDA_PixelWaitAppearColor
    Waits until given pixel has given color.

  Throws:
    Timeout reached at RDA_PixelWaitAppearColor: Color not changed
*/
RDA_PixelWaitAppearColor(color, x, y, timeout, delay) {
  local startTime := A_TickCount, scolor

  RDA_Log_Debug(A_ThisFunc "(" . color . ", (" . x . "," . y . "), " . timeout . ", " . delay . ")")

  if (timeout <= 0) {
    throw RDA_Exception("Invalid timeout value: " . timeout)
  }

  loop
  {
    scolor := RDA_PixelGetColor(x, y)
    if (color == scolor) {
      return
    }

    if (A_TickCount >= startTime + timeout) {
      RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
      throw RDA_Exception("Timeout reached at " . A_ThisFunc . ": Color not changed")
    }

    sleep % delay
  }
}
/*!
  Function: RDA_PixelWaitDisappearColor
    Waits until given pixel change from given color.

  Throws:
    Timeout reached at RDA_PixelWaitDisappearColor: Color not changed
*/
RDA_PixelWaitDisappearColor(color, x, y, timeout, delay) {
  local startTime := A_TickCount, scolor

  RDA_Log_Debug(A_ThisFunc "(" . color . ", (" . x . "," . y . "), " . timeout . ", " . delay . ")")

  if (timeout <= 0) {
    throw RDA_Exception(A_ThisFunc . " Invalid timeout value: " . timeout)
  }

  loop
  {
    scolor := RDA_PixelGetColor(x, y)
    if (color != scolor) {
      return
    }

    if (A_TickCount >= startTime + timeout) {
      RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
      throw RDA_Exception("Timeout reached at " . A_ThisFunc . ": Color not changed")
    }

    sleep % delay
  }
}

/*!
  Function: RDA_PixelSearchColor
    Searches a region of the screen for a pixel of the specified color.

  Remarks:
    https://www.autohotkey.com/docs/v1/lib/PixelSearch.htm

  Example:
    ======= AutoHotKey =======
    pos := RDA_PixelSearchColor(0xFF0000, 100, 100, 50, 50)
    msgbox % "x = " . pos.x . " y = " . pos.y
    ==========================

  Parameters:
    automation - <RDA_Automation>
    color - number - RGB color
    x - number - X screen coordinate
    y - number - Y screen coordinate
    w - number - Width
    h - number - height
    variation - number - Number of shades of variation. See: https://www.autohotkey.com/docs/v1/lib/PixelSearch.htm#Parameters

  Throws:
    Color not found

  Returns:
    <RDA_ScreenPosition>
*/
RDA_PixelSearchColor(automation, color, x, y, w, h, variation := "") {
  local ox, oy, x2 := x + w, y2:= y + h, p
  RDA_Assert(automation, A_ThisFunc . " automation is null")

  RDA_Log_Debug(A_ThisFunc . "(color = " color . ", (" . x . ", "  . y . "), (" . w . ", "  . h . "), "  . variation . ")")

  CoordMode Pixel
  CoordMode, Mouse, Screen
  PixelSearch, ox, oy, %x%, %y%, %x2%, %y2%, %color% , %variation%, RGB

  if (ErrorLevel != 0) {
    RDA_Log_Error(A_ThisFunc . " error level = " . ErrorLevel)
    throw RDA_Exception("Color not found")
  }
  p := new RDA_ScreenPosition(automation, ox, oy)
  RDA_Log_Debug(A_ThisFunc . " = " . p.toString())
  return p
}

/*!
  Function: RDA_ImageSearch
    Searches a region of the screen for an image and returns its position

    Use: https://www.autohotkey.com/docs/commands/ImageSearch.htm

  Example:
    ======= AutoHotKey =======
    image := Configuration.rootDir . "\images\button.png"
    ; search the entire screen
    pos := RDA_ImageSearch(automation, image, 5, automation.screen(1))
    ; search the entire screen with 120 sensibility
    pos := RDA_ImageSearch(automation, image, 120, automation.screen(1))
    ; search from (0,0) to (1024,768)
    pos := RDA_ImageSearch(automation, image, 5, new RDA_ScreenRegion.fromPoints(automation, 0, 0, 1024, 768))
    ==========================

  Parameters:
    automation - <RDA_Automation>
    imagePath - string - Absolute image path
    sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
    screenRegion - <RDA_ScreenRegion> - Window region (default - entire screen)
    options - string - ImageSearch rest of the options arg (sensibility and path are handled)

  Throws:
    File not found
    ImageSearch failed
    Image not found in the screen

  Returns:
    <RDA_ScreenPosition>
*/
RDA_ImageSearch(automation, imagePath, sensibility, screenRegion, options := "") {
  local x1, x2, y1, y2, err, FoundX, FoundY

  if (!FileExist(imagePath)) {
    throw RDA_Exception("File not found: " . imagePath)
  }

  CoordMode Pixel
  CoordMode, Mouse, Screen

  if (options) {
    options := "*" . sensibility . " " . options . " " . imagePath
  } else {
    options := "*" . sensibility . " " . imagePath
  }

  if (!screenRegion) {
    RDA_Log_Debug(A_ThisFunc . " region (0, 0, " . A_ScreenWidth . ", " . A_ScreenHeight . ") options = " . options)
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, % options
  } else {
    x1 := screenRegion.origin.x
    y1 := screenRegion.origin.y
    x2 := screenRegion.origin.x + screenRegion.rect.w
    y2 := screenRegion.origin.y + screenRegion.rect.h
    RDA_Log_Debug(A_ThisFunc . " region (" . x1 . ", " . y1 . ", " . x2 . ", " . y2 . ") options = " . options)
    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, % options
  }
  err := ErrorLevel

  RDA_Log_Debug(A_ThisFunc . " result (" . FoundX .  " ," . FoundY .  ") ErrorLevel = " . err)

  if (err == 2) {
    throw RDA_Exception("ImageSearch failed")
  } else if (err == 1) {
    throw RDA_Exception("Image not found in the screen: " . imagePath)
  }

  return new RDA_ScreenPosition(automation, FoundX, FoundY)
}

/*!
  Function: RDA_ImagesWaitAppear
    Searches a region of the screen for first image until it appears and return its position

  Example:
    ======= AutoHotKey =======
    images := [Configuration.rootDir . "\images\button.png", Configuration.rootDir . "\images\button2.png"]
    index := RDA_ImagesWaitAppear(images, 10)
    ==========================

  Parameters:
    automation - <RDA_Automation>
    imagePathList - string[] - Absolute image paths
    sensibility - number - number from 0-255, 0 means exact
    screenRegion - <RDA_ScreenRegion> - Window region, 0 means the entire screen
    options - string - ImageSearch rest of the options arg (sensibility and path are handled)
    timeout - number - Timeout, in miliseconds
    delay - number - Delay, in miliseconds

  Throws:
    Timeout reached at RDA_ImagesWaitAppear. Image(s) not found.

  Returns:
    <RDA_ScreenPosition> - position the image found

*/
RDA_ImagesWaitAppear(automation, imagePathList, sensibility, screenRegion, options, timeout, delay) {
  local startTime := A_TickCount, pos, e
  RDA_Log_Debug(A_ThisFunc . "(images = " . RDA_JSON_stringify(imagePathList) . ", sensibility = " . sensibility . ", options = " . options . ", timeout = " . timeout . ", timeout = " . delay . ")")

  loop {
    loop % imagePathList.length() {
      try {
        pos := RDA_ImageSearch(automation, imagePathList[A_Index], sensibility, screenRegion, options)
        return pos
      } catch e {
        RDA_Log_Error(e.message)
      }
    }

    if (A_TickCount >= startTime + timeout) {
      RDA_Log_Debug(A_ThisFunc . " timeout reached")
      throw RDA_Exception("Timeout reached at " . A_ThisFunc . ". Image(s) not found.")
    }

    sleep % delay
  }
}

/*!
  Function: RDA_ImagesWaitDisappear
    Searches a region of the screen for one image until it disappears

  Example:
    ======= AutoHotKey =======
    images := [Configuration.rootDir . "\images\button.png", Configuration.rootDir . "\images\button2.png"]
    index := RDA_ImagesWaitDisappear(images, 10)
    ==========================

  Parameters:
    automation - <RDA_Automation>
    imagePathList - string[] - Absolute image paths
    sensibility - number - number from 0-255, 0 means exact
    screenRegion - <RDA_ScreenRegion> - Window region, 0 means the entire screen
    options - string - ImageSearch rest of the options arg (sensibility and path are handled)
    timeout - number - Timeout, in miliseconds
    delay - number - Delay, in miliseconds

  Throws:
    Timeout reached at RDA_ImagesWaitDisappear. Image(s) not found.

  Returns:
    number - Index of the image not found

*/
RDA_ImagesWaitDisappear(automation, imagePathList, sensibility, screenRegion, options, timeout, delay) {
  local startTime := A_TickCount, pos, e
  RDA_Log_Debug(A_ThisFunc . "(images = " . RDA_JSON_stringify(imagePathList) . ", sensibility = " . sensibility . ", options = " . options . ", timeout = " . timeout . ", timeout = " . delay . ")")

  loop {
    loop % imagePathList.length() {
      try {
        RDA_ImageSearch(automation, imagePathList[A_Index], sensibility, screenRegion, options)
      } catch e {
        RDA_Log_Debug(A_ThisFunc . " result = " . A_Index . " not found")
        return A_Index
      }
    }

    if (A_TickCount >= startTime + timeout) {
      RDA_Log_Debug(A_ThisFunc . " timeout reached")
      throw RDA_Exception("Timeout reached at " . A_ThisFunc . ". Image(s) not found.")
    }

    sleep % delay
  }
}

/*!
  Function: RDA_Screenshot
    Creates an screenshot

  Example:
    ======= AutoHotKey =======
    images := [Configuration.rootDir . "\images\button.png", Configuration.rootDir . "\images\button2.png"]
    index := RDA_ImagesWaitDisappear(images, 10)
    ==========================

  Parameters:
    nL - number - left
    nT - number - top
    nW - number - width
    nH - number - height
    file - string - output file path (default clipboard)
    captureCursor - boolean

  Returns:
    boolean - If screenshot is successfully
*/
RDA_Screenshot(nL, nT, nW, nH, file := 0, captureCursor :=  false) {
  local mDC, hBM, oBM, hDC,
  RDA_Log_Debug(A_ThisFunc . "(" . nL . ", " . nT . ", " . nW . ", " . nH . ", " . file . ", " . captureCursor . ")")
  try {
    mDC := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
    hBM := _RDA_Screenshot_CreateDIBSection(mDC, nW, nH)
    oBM := DllCall("SelectObject", "ptr", mDC, "ptr", hBM, "ptr")
    hDC := DllCall("GetDC", "ptr", 0, "ptr")
    DllCall("BitBlt", "ptr", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "ptr", hDC, "int", nL, "int", nT, "Uint", 0x40CC0020)
    DllCall("ReleaseDC", "ptr", 0, "ptr", hDC)
    if captureCursor {
      _RDA_Screenshot_CaptureMouse(mDC, nL, nT)
    }
    DllCall("SelectObject", "ptr", mDC, "ptr", oBM)
    DllCall("DeleteDC", "ptr", mDC)

    if (file) {
      _RDA_Screenshot_Convert(hBM, file, 100)
      DllCall("DeleteObject", "ptr", hBM)
    } else {
      _RDA_Screenshot_SetClipboardData(hBM)
    }
  } catch e {
    RDA_Log_Error(A_ThisFunc . " " . e.message)
    return false
  }

  return true
}

; internal
_RDA_Screenshot_CaptureMouse(hDC, nL, nT) {
  local mi, bShow, hCursor, xCursor, yCursor, xHotspot, yHotspot, hBMMask, hBMColor
  RDA_Log_Debug(A_ThisFunc . "(" . !!hDC . ", " . nL . ", " . nT . ")")

  VarSetCapacity(mi, 32, 0), Numput(16+A_PtrSize, mi, 0, "uint")
  DllCall("GetCursorInfo", "ptr", &mi)
  bShow   := NumGet(mi, 4, "uint")
  hCursor := NumGet(mi, 8)
  xCursor := NumGet(mi,8+A_PtrSize, "int")
  yCursor := NumGet(mi,12+A_PtrSize, "int")

  DllCall("GetIconInfo", "ptr", hCursor, "ptr", &mi)
  xHotspot := NumGet(mi, 4, "uint")
  yHotspot := NumGet(mi, 8, "uint")
  hBMMask  := NumGet(mi,8+A_PtrSize)
  hBMColor := NumGet(mi,16+A_PtrSize)

  If bShow
    DllCall("DrawIcon", "ptr", hDC, "int", xCursor - xHotspot - nL, "int", yCursor - yHotspot - nT, "ptr", hCursor)
  If hBMMask
    DllCall("DeleteObject", "ptr", hBMMask)
  If hBMColor
    DllCall("DeleteObject", "ptr", hBMColor)
}

_RDA_Screenshot_Convert(sFileFr, sFileTo, nQuality) {
  local offset, sDirTo, sExtTo, sNameTo, hGdiPlus, az, offset, hBitmap, pi
  local struct_size, nSize, pParam, pImage, pToken, hBM, nCount, pCodec, si, ci

  RDA_Log_Debug(A_ThisFunc . "(" . sFileFr . ", " . sFileTo . ", " . nQuality . ")")

  SplitPath, sFileTo, , sDirTo, sExtTo, sNameTo

  If Not hGdiPlus := DllCall("LoadLibrary", "str", "gdiplus.dll", "ptr")
    Return  sFileFr+0 ? _RDA_Screenshot_SaveHBITMAPToFile(sFileFr, sDirTo (sDirTo == "" ? "" : "\") sNameTo ".bmp") : ""
  VarSetCapacity(si, 16, 0), si := Chr(1)
  pToken := 0
  DllCall("gdiplus\GdiplusStartup", "UintP", pToken, "ptr", &si, "ptr", 0)

  pImage := 0
  DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", sFileFr, "ptr", 0, "ptr*", pImage)
  nSize := nCount:= 0
  DllCall("gdiplus\GdipGetImageEncodersSize", "UintP", nCount, "UintP", nSize)
  VarSetCapacity(ci,nSize,0)
  DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "ptr", &ci)
  struct_size := 48+7*A_PtrSize, offset := 32 + 3*A_PtrSize, pCodec := &ci - struct_size
  Loop, % nCount
    If InStr(StrGet(Numget(offset + (pCodec+=struct_size)), "utf-16") , "." . sExtTo)
      break

  If (InStr(".JPG.JPEG.JPE.JFIF", "." . sExtTo) && nQuality<>"" && pImage && pCodec < &ci + nSize)
  {
    DllCall("gdiplus\GdipGetEncoderParameterListSize", "ptr", pImage, "ptr", pCodec, "UintP", nCount)
    VarSetCapacity(pi,nCount,0), struct_size := 24 + A_PtrSize
    DllCall("gdiplus\GdipGetEncoderParameterList", "ptr", pImage, "ptr", pCodec, "Uint", nCount, "ptr", &pi)
    Loop, % NumGet(pi,0,"uint")
      If (NumGet(pi,struct_size*(A_Index-1)+16+A_PtrSize,"uint")=1 && NumGet(pi,struct_size*(A_Index-1)+20+A_PtrSize,"uint")=6)
      {
        pParam := &pi+struct_size*(A_Index-1)
        NumPut(nQuality,NumGet(NumPut(4,NumPut(1,pParam+0,"uint")+16+A_PtrSize,"uint")),"uint")
        Break
      }
  }

  if (pCodec < &ci + nSize) {
    DllCall("gdiplus\GdipSaveImageToFile", "ptr", pImage, "wstr", sFileTo, "ptr", pCodec, "ptr", 0)
  } else {
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", pImage, "ptr*", hBitmap, "Uint", 0)
    _RDA_Screenshot_SetClipboardData(hBitmap)
    DllCall("gdiplus\GdipDisposeImage", "ptr", pImage)
  }

  DllCall("gdiplus\GdiplusShutdown" , "Uint", pToken)
  DllCall("FreeLibrary", "ptr", hGdiPlus)
}

_RDA_Screenshot_SaveHBITMAPToFile(hBitmap, sFile) {
  local oi, fObj

  VarSetCapacity(oi,104,0)
  DllCall("GetObject", "ptr", hBitmap, "int", 64+5*A_PtrSize, "ptr", &oi)
  fObj := FileOpen(sFile, "w")
  fObj.WriteShort(0x4D42)
  fObj.WriteInt(54+NumGet(oi,36+2*A_PtrSize,"uint"))
  fObj.WriteInt64(54<<32)
  fObj.RawWrite(&oi + 16 + 2*A_PtrSize, 40)
  fObj.RawWrite(NumGet(oi, 16+A_PtrSize), NumGet(oi,36+2*A_PtrSize,"uint"))
  fObj.Close()
}

_RDA_Screenshot_CreateDIBSection(hDC, nW, nH, bpp := 32, ByRef pBits := "") {
  ; this cannot be local! need to be static because the memory will be used outside this function
  static bi := ""

  VarSetCapacity(bi, 40, 0)
  NumPut(40, bi, "uint")
  NumPut(nW, bi, 4, "int")
  NumPut(nH, bi, 8, "int")
  NumPut(bpp, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
  Return DllCall("gdi32\CreateDIBSection", "ptr", hDC, "ptr", &bi, "Uint", 0, "UintP", pBits, "ptr", 0, "Uint", 0, "ptr")
}

_RDA_Screenshot_SetClipboardData(hBitmap) {
  local oi, sz, hDIB, pDIB
  VarSetCapacity(oi,104,0)
  DllCall("GetObject", "ptr", hBitmap, "int", 64+5*A_PtrSize, "ptr", &oi)
  sz := NumGet(oi,36+2*A_PtrSize,"uint")
  hDIB := DllCall("GlobalAlloc", "Uint", 2, "Uptr", 40+sz, "ptr")
  pDIB := DllCall("GlobalLock", "ptr", hDIB, "ptr")
  DllCall("RtlMoveMemory", "ptr", pDIB, "ptr", &oi + 16 + 2*A_PtrSize, "Uptr", 40)
  DllCall("RtlMoveMemory", "ptr", pDIB+40, "ptr", NumGet(oi, 16+A_PtrSize), "Uptr", sz)
  DllCall("GlobalUnlock", "ptr", hDIB)
  DllCall("DeleteObject", "ptr", hBitmap)
  DllCall("OpenClipboard", "ptr", 0)
  DllCall("EmptyClipboard")
  DllCall("SetClipboardData", "Uint", 8, "ptr", hDIB)
  DllCall("CloseClipboard")
}

;
; "xPath" support limited but enought :)
;

_RDA_xPath_AddIdentifier(tokenize, identifier) {
  local

  if (RegExMatch(identifier, "[0-9]+")) {
    tokenize.push({type: "literal", literal: identifier})
    return
  }

  switch (identifier) {
    case "and":
      tokenize.push({type: "operator", operator: "&&"})
    case "or":
      tokenize.push({type: "operator", operator: "||"})
    default:
      tokenize.push({type: "identifier", identifier: identifier})
  }

}

_RDA_xPath_Tokenize(xpath) {
  local

  tokenize := []
  pos := 1
  len := StrLen(xpath)
  identifier := ""

  while (true) {
    if (pos > len) {
      break
    }

    c := SubStr(xpath, pos, 1)

    ; skip whitespace
    if (c == " " || c == "\t" || c == "\r" || c == "\n") {
      if (StrLen(identifier)) {
        _RDA_xPath_AddIdentifier(tokenize, identifier)
        identifier := ""
      }

      pos += 1
      continue
    }

    ; token
    if (c == "/" || c == "[" || c == "]" || c == "=" || c == "!" || c == ".") {
      if (StrLen(identifier)) {
        _RDA_xPath_AddIdentifier(tokenize, identifier)
        identifier := ""
      }
      ; multi-char operators
      if (c == "!") {
        pos += 1
        c := SubStr(xpath, pos, 1)

        if (c != "=") {
          throw RDA_Exception("invalid operator !, shall be follow by: = (!=)")
        }

        tokenize.push({type: "operator", operator: "!="})
      } else {
        tokenize.push({type: "operator", operator: c})
      }
      pos += 1
      continue
    }
    ; literal
    if (c == """" || c == "'") {
      if (StrLen(identifier)) {
        _RDA_xPath_AddIdentifier(tokenize, identifier)
        identifier := ""
      }
      backslashes := 0
      literal := ""
      while(pos < len) {
        pos += 1
        cx := SubStr(xpath, pos, 1)

        RDA_Log_Debug("schar[" . pos . "]: " . cx)

        if (cx == c) {
          if (Mod(backslashes, 2) == 0) {
            break
          } else {
            ; remove last "\"
            literal := SubStr(literal, 1, StrLen(literal) - 1)
          }
        }

        if (cx == "\") {
          backslashes += 1
          if (Mod(backslashes, 2) == 0) {
            continue
          }
        } else {
          backslashes = 0
        }

        literal .= cx
      }
      if (cx != c) {
        RDA_Log_Error(A_ThisFunc . " invalid token found")
        RDA_Log_Error(literal)
        throw RDA_Exception("Unclosed string literal")
      }
      tokenize.push({type: "literal", literal: literal})
      pos += 1
      continue
    }

    ; identifier
    identifier .= c
    pos += 1
  }

  if (StrLen(identifier)) {
    _RDA_xPath_AddIdentifier(tokenize, identifier)
  }

  RDA_Log_Debug(RDA_JSON_stringify(tokenize, 0, 2))

  return tokenize
}

_RDA_xPath_ParseSubExpr(stack) {
  local

  if (stack.length() < 3) {
    RDA_Log_Error(A_ThisFunc . " Invalid token found")
    RDA_Log_Error(stack)
    throw RDA_Exception("Requested to parse and expression but not enought tokens found")
  }

  left := stack[1]
  op := stack[2]
  right := stack[3]

  RDA_Log_Debug("--expr--")
  RDA_Log_Debug(left)
  RDA_Log_Debug(op)
  RDA_Log_Debug(right)
  RDA_Log_Debug("--expr--")

  stack.RemoveAt(1, 3)
  if (left.type == "operator") {
    RDA_Log_Error(A_ThisFunc . " invalid token found")
    RDA_Log_Error(left)
    throw RDA_Exception("Left hand side must be an identifier or literal")
  }
  if (op.type != "operator") {
    RDA_Log_Error(A_ThisFunc . " invalid token found")
    RDA_Log_Error(op)
    throw RDA_Exception("After identifier or literal must be an operator")
  }
  if (right.type == "operator") {
    RDA_Log_Error(A_ThisFunc . " invalid token found")
    RDA_Log_Error(right)
    throw RDA_Exception("Right hand side must be an identifier or literal")
  }

  switch (op.operator) {
    case "=":
      return {"action": "xpathFilterMatch", "arguments": [left, right]}

    case "!=":
      return {"action": "xpathFilterNotMatch", "arguments": [left, right]}
    default:
    RDA_Log_Error(A_ThisFunc . " invalid token found")
    RDA_Log_Error(op)
    throw RDA_Exception("Operator not implemented")
  }
}
; a + b                                     3
; a + b and a + b                           7
; a + b and a + b or a + b                  11
; a + b and a + b or a + b and a + b        15
_RDA_xPath_ParseExpr(stack, nodes) {
  local

  RDA_Log_Debug(stack)

  expr := 0

  pos := 1
  while(stack.length()) {
    if (!expr) {
      expr := _RDA_xPath_ParseSubExpr(stack)
    } else {
      ; now the first shall be and operator!
      logicalOp := stack[1]
      stack.RemoveAt(1, 1)

      if (logicalOp.operator != "&&" && logicalOp.operator != "||") {
        RDA_Log_Error(A_ThisFunc . " Invalid token found")
        RDA_Log_Error(logicalOp)
        throw RDA_Exception("Expected a logical operator")
      }
      if (logicalOp.operator == "&&") {
        expr := {"action": "xpathLogicalAnd", "arguments": [expr, _RDA_xPath_ParseSubExpr(stack)]}
      } else {
        expr := {"action": "xpathLogicalOr", "arguments": [expr, _RDA_xPath_ParseSubExpr(stack)]}
      }
    }
    ; stack.pop() ; debug empty
  }
  nodes.push(expr)
}

_RDA_xPath_Parse(tokens) {
  local

  ;if (tokens[1].type != "operator") {
    if (tokens[1].operator != "/" && tokens[1].operator != ".") {
      throw RDA_Exception("Query shall start with slash or dot")
    }
  ;}

  nodes := []

  pos := 1
  while (true) {
    if (pos > tokens.length()) {
      break
    }

    RDA_Log_Debug(tokens[pos])

    switch (tokens[pos].type) {
      case "operator": {
        switch (tokens[pos].operator) {
          case ".": {
            ; start ?
            if (!nodes.length()) {
              ; subquery
              if (tokens[pos + 1].operator != "/") {
                throw RDA_Exception("expected slash after dot ""./""")
              }
              ; .//
              if (tokens[pos + 1].operator == "/" && tokens[pos + 2].operator == "/") {
                pos += 2
                nodes.push({ "action": "getDescendants" })
              ; ./
              } else if (tokens[pos + 1].operator == "/") {
                pos += 1
                nodes.push({ "action": "getCurrent" })
              }
            } else {
              ; ignore just one
              ; two -> getParent
              if (tokens[pos + 1].operator == ".") {
                pos += 1
                nodes.push({ "action": "getParent" })
              }
            }
          }
          case "/": {
            ; /
            ; //
            ; /..
            if (tokens[pos + 1].operator == "/") {
              pos += 1
              nodes.push({ "action": "getDescendants" })
            } else if (tokens[pos + 1].operator == "." && tokens[pos + 2].operator == ".") {
              pos += 2
              nodes.push({ "action": "getParent" })
            } else {
              nodes.push({ "action": "getChildren" })
            }
          }
          case "[": {
            ; now it will appear a (identifier|literal) operator (identifier|literal)
            ; until "]"
            stack := []
            pos += 1 ; skip  [

            while(pos < tokens.length() + 1 && tokens[pos].operator != "]") {
              stack.push(tokens[pos])
              pos += 1
            }

            _RDA_xPath_ParseExpr(stack, nodes)

            if (tokens[pos].operator != "]") {
              throw RDA_Exception("Unclosed brace found")
            }
            pos += 1
            continue
          }
          default: {
            RDA_Log_Error(A_ThisFunc . " Invalid token found")
            RDA_Log_Error(tokens[pos])
            throw RDA_Exception("Invalid operator found")
          }
        }
      }
      case "identifier": {
        ; TODO handle only one!
        if (tokens[pos].identifier != "*") {
          ; number -> by position
          ; other -> by type
          nodes.push({action: "xpathFilterMatch"
            , arguments: [{"identifier": "@Type", "type": "identifier"}
              , {"type": "literal", "literal": tokens[pos].identifier}]})
        }
      }
      case "literal": {
        ; number -> by position
        nodes.push({action: "xpathFilterMatch"
          , arguments: [{"identifier": "@Idx", "type": "identifier"}
            , {"type": "literal", "literal": tokens[pos].literal}]})
      }
      default: {
        RDA_Log_Error(A_ThisFunc . " Invalid token at " . pos)
        RDA_Log_Error(tokens[pos])
        throw RDA_Exception("Invalid token found")
      }
    }

    pos += 1
  }

  RDA_Log_Debug(RDA_JSON_stringify(nodes, 0, 2))
  return nodes
}

/*!
  class: RDA_xPathAction
    TODO
*/

/*!
  Function: RDA_xPath_Parse
    Parses given xpath.

  Remarks:
    It a reduced version. It supports

    * descendant search: //

    * children search: /

    * type (tagName) search

    * atribute search with and/or expressions.

  Parameters:
    xpath - string - xpath like string

  Example:
    ======= AutoHotKey =======
    ; Returns all List with name xxx
    x := RDA_xPath_Parse("//List[@name = 'xxx']")
    ; search all list and returns label children
    x := RDA_xPath_Parse("//List/Label")
    ; Returns all nodes with type document or edit
    x := RDA_xPath_Parse("//*[@type = 'Document' or @type = 'Edit']")
    ; Returns Labels under a list
    x := RDA_xPath_Parse("//List/Label")
    ==========================

  Returns:
    RDA_xPathAction[]
*/
RDA_xPath_Parse(xpath) {
  local
  global RDA_Log_Level

  ; disable log, it's to verbose!
  RDA_Log_Level := 2

  try {
    tokens := _RDA_xPath_Tokenize(xpath)
    actions := _RDA_xPath_Parse(tokens)

    RDA_Log_Level := 3
    return actions
  } catch e {
    RDA_Log_Level := 3
    RDA_Log_Error(A_ThisFunc . " " . e.message)
    throw e
  }
}


RDA_Elements_getName(list) {
  local ret := []

  loop % list.length {
    ret.push(list[A_Index].getName())
  }

  return ret
}
