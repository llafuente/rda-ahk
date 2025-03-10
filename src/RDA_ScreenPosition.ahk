/*!
  class: RDA_ScreenPosition
    Represents a position (x,y) in the screen

  Remarks:
    It not bound to a window so any operation made here won't change any
    window.
*/
class RDA_ScreenPosition extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_ScreenPosition)

  ; internal
  automation := 0
  /*!
    Property: x
      number - x
  */
  x := 0
  /*!
    Property: y
      number - y
  */
  y := 0
  /*!
    Constructor: RDA_ScreenPosition

    Parameters:
      automation - <RDA_Automation>
      x - number - screen position x
      y - number - screen position y
  */
  __New(automation, x, y) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.x := x
    this.y := y
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "RDA_ScreenPosition{x: " . this.x . ", y: " . this.y . "}"
  }
  /*!
    Method: clone
      Duplicates screen position

    Returns:
      <RDA_ScreenRegion>
  */
  clone() {
    return new RDA_ScreenPosition(this.automation, this.x, this.y)
  }
  /*!
    Method: getLength
      Calculates the length to origin

    Returns:
      number
  */
  getLength() {
    local v := Sqrt(this.x * this.x + this.y * this.y)
    RDA_Log_Debug(A_ThisFunc . " = " . v)
    return v
  }
  /*!
    Method: move
      Moves (Adds) to current screen position

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_ScreenPosition>
  */
  move(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ")")

    this.x += x
    this.y += y

    return this
  }
  /*!
    Method: set
      Sets current screen position

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_ScreenPosition>
  */
  set(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ")")

    this.x := x
    this.y := y

    return this
  }
  /*!
    Method: add
      Adds given screen position

    Parameters:
      screenPos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  add(screenPos) {
    this.x += screenPos.x
    this.y += screenPos.y

    return this
  }
  /*!
    Method: subtract
      Subtracts given screen position

    Parameters:
      screenPos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  subtract(screenPos) {
    this.x -= screenPos.x
    this.y -= screenPos.y

    return this
  }
  /*!
    Method: mouseMove
      Alias of <RDA_MouseMove>

    Returns:
      <RDA_ScreenPosition>
  */
  mouseMove() {
    RDA_MouseMove(this.automation, 0, this.x, this.y)

    return this
  }
  /*!
    Method: click
      Alias of <RDA_AutomationMouse.click>

    Returns:
      <RDA_ScreenPosition>
  */
  click() {
    this.automation.mouse().click(this.x, this.y)

    return this
  }
  /*!
    Method: rightClick
      Alias of <RDA_AutomationMouse.rightClick>

    Returns:
      <RDA_ScreenPosition>
  */
  rightClick() {
    this.automation.mouse().rightClick(this.x, this.y)

    return this
  }
  /*!
    Method: doubleClick
      Alias of <RDA_AutomationMouse.doubleClick>

    Returns:
      <RDA_ScreenPosition>
  */
  doubleClick() {
    this.automation.mouse().doubleClick(this.x, this.y)

    return this
  }
  /*!
    Method: getColor
      Retrieves the color of the pixel at the specified screen position. (<RDA_PixelGetColor>)

    Remarks:
      0xFFFFFFFF is the actual value returned when Workstation is locked

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      new RDA_ScreenPosition(automation, 50, 50).getColor()
      ==========================

    Returns:
      number - RGB color
  */
  getColor() {
    return RDA_PixelGetColor(this.x, this.y)
  }
  /*!
    Method: waitAppearColor
      Waits the current pixel color to change to the given one (any or given one)

    Parameters:
      color - number -RGB color.
      timeout - number - timeout, in miliseconds
      delay - number - retry delay, in miliseconds

    Example:
      ======= AutoHotKey =======
      ; when 50,50 is red it will continue.
      automation := RDA_Automation()
      new RDA_ScreenPosition(automation, 50, 50).waitAppearColor(0xFF0000)
      ==========================

    Throws:
      Timeout reached: Color not changed

    Returns:
      <RDA_ScreenPosition>
  */
  waitAppearColor(color, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_PixelWaitAppearColor(color, this.x, this.y, timeout, delay)

    return this
  }
  /*!
    Method: waitDisappearColor
      Waits the current pixel color to change to the given one (any or given one)

    Parameters:
      color - number -RGB color (default, use current color)
      timeout - number - timeout, in miliseconds
      delay - number - retry delay, in miliseconds

    Example:
      ======= AutoHotKey =======
      ; when 50,50 is red it will continue.
      automation := RDA_Automation()
      new RDA_ScreenPosition(automation, 50, 50).waitDisappearColor(0xFF0000)
      ==========================

    Throws:
      Timeout reached: Color not changed

    Returns:
      <RDA_ScreenPosition>
  */
  waitDisappearColor(color, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_PixelWaitDisappearColor(color, this.x, this.y, timeout, delay)

    return this
  }

  /*!
    Method: relativeTo
      Changes current screen position to relative position

    Parameters:
      win - RDA_Window -window

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      windows := automation.windows()
      win := windows.findOne({"process": "xxx.exe"})
      winPos := new RDA_ScreenPosition(automation, 50, 50).relativeTo(win)
      ==========================

    Returns:
      <RDA_WindowPosition>
  */
  relativeTo(win) {
    local
    global RDA_WindowPosition

    origin := win.getPosition()

    return new RDA_WindowPosition(this.automation, win, this.x - origin.x, this.y - origin.y)
  }
  /*!
    Method: toWindow
      Alias of <RDA_ScreenPosition.relativeTo>

    Returns:
      <RDA_WindowPosition>
  */
  toWindow(win) {
    return this.relativeTo(win)
  }
}

