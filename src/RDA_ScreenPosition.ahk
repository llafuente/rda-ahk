/*!
  Class: RDA_ScreenPosition
    Represents a position (x,y) in the screen

  Extends: RDA_Position

  Remarks:
    It not bound to a window so any operation made here won't change any
    window.
*/
class RDA_ScreenPosition extends RDA_Position {
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
    this.x := Format("{:d}", x) + 0
    this.y := Format("{:d}", y) + 0
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
    RDA_Log_Debug(A_ThisFunc)
    return new RDA_ScreenPosition(this.automation, this.x, this.y)
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
      Changes current screen position to window position

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

  ; internal
  toScreen() {
    return this
  }
}

