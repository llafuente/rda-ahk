/*!
  Class: RDA_AutomationMouse
*/
class RDA_AutomationMouse extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationMouse)

  automation := 0

  /*!
    Constructor: RDA_AutomationMouse

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: click
      Performs a left click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  click(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "LEFT", 1, x, y)

    return this
  }
  /*!
    Method: rightClick
      Performs a right click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  rightClick(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "RIGHT", 1, x, y)

    return this
  }
  /*!
    Method: doubleClick
      Performs a lft double click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  doubleClick(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "LEFT", 2, x, y)

    return this
  }
  /*!
    Method: move
      See <RDA_MouseRelativeMove>

    Returns:
      <RDA_AutomationMouse>
  */
  move(x, y) {
    RDA_MouseRelativeMove(this.automation, x, y)

    return this
  }
  /*!
    Method: moveTo
      See <RDA_MouseMove>

    Returns:
      <RDA_AutomationMouse>
  */
  moveTo(x, y) {
    RDA_MouseMove(this.automation, 0, x, y)

    return this
  }
  /*!
    Method: get
      See <RDA_MouseGetPosition>

    Returns:
      <RDA_ScreenPosition>
  */
  get() {
    return RDA_MouseGetPosition(this.automation)
  }
  /*!
    Method: getPosition
      See <RDA_MouseGetPosition>

    Returns:
      <RDA_ScreenPosition>
  */
  getPosition() {
    return this.get()
  }
  /*!
    Method: getCursor
      Retrieves mouse cursor

    Returns:
      string - AppStarting, Arrow, Cross, Help, IBeam, Icon, No, Size, SizeAll, SizeNESW, SizeNS, SizeNWSE, SizeWE, UpArrow, Wait, Unknown
  */
  getCursor() {
    local

    c := A_Cursor
    RDA_Log_Debug(A_ThisFunc . " = " . c)
    return c
  }
  /*!
    Method: isCursor
      Checks if current cursor in not in the given list

    Parameters:
      list_or_value - string | string[] - List of values

    Returns:
      boolean
  */
  isCursor(list_or_value) {
    local
    global JSON
    ; arrayize
    list := list_or_value
    if (StrLen(list_or_value) > 0) {
      list := [list_or_value]
    }

    RDA_Log_Debug(A_ThisFunc . "(" . JSON.dump(list) . ")")

    return RDA_Array_IndexOf(list, this.getCursor()) > 0
  }
  /*!
    Method: expectCursor
      Asserts if current cursor in not in the given list

    Remarks:
      use: minimum_time = 0 to detect the first (instant) change

    Parameters:
      list_or_value - string | string[] - List of values
      errorMessage - string - Exception error message

    Throws:
      Unexpected mouse cursor value

    Returns:
      <RDA_AutomationMouse>
  */
  expectCursor(list_or_value, errorMessage := "Unexpected mouse cursor value") {
    local

    if (this.isCursor(list_or_value)) {
      return this
    }

    throw RDA_Exception(errorMessage)
  }
  /*!
    Method: waitCursor
      Waits until cursor change to given list_or_value during at least given minimum_time

    Remarks:
      use: minimum_time = 0 to detect the first (instant) change

    Parameters:
      list_or_value - string | string[] - List of values
      minimum_time - Minimum time to consider cursor change is stable, in miliseconds
      timeout - timeout in miliseconds
      delay - number - Time between retries, in miliseconds

    Returns:
      <RDA_ScreenPosition>
  */
  waitCursor(list_or_value, minimum_time := 500, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay

    ; arrayize
    list := list_or_value
    if (StrLen(list_or_value) > 0) {
      list := [list_or_value]
    }

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(list) . ", timeout = " . timeout . " delay = " . delay . ")")

    startTime := A_TickCount
    changeTime := 0

    loop {
      cursor := A_Cursor
      RDA_Log_Debug(A_ThisFunc . " " . cursor . " in? " . RDA_JSON_stringify(list))
      if (RDA_Array_IndexOf(list, cursor) > 0) {
        if (changeTime == 0) {
          changeTime := A_TickCount
        }
        ; do not else, to detect instance change with minimum_time = 0
        if (A_TickCount >= changeTime + minimum_time) {
          RDA_Log_Error(A_ThisFunc " mouse is stable during: " . changeTime - A_TickCount)
          return this
        }
        continue ; do not timeout while checking minimum_time
      } else {
        ; reset stability time
        changeTime := 0
      }

      if (A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout reached")
        throw RDA_Exception(A_ThisFunc . " expected cursor to change")
      }

      sleep % delay
    }

    throw RDA_Exception("unreachable")
  }
}
