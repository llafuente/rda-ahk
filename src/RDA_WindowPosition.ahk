/*!
  Class: RDA_WindowPosition
    Represents a position (x,y) relative to a window

  Remarks:
    If the windows gets destroyed all method will throw.

  Returns:
    <RDA_WindowPosition>
*/
class RDA_WindowPosition {
  automation := 0
  window := 0
  x := 0
  y := 0

  /*!
    Constructor: RDA_WindowPosition

    Parameters:
      automation - <RDA_Automation>
      x - number - screen position x
      y - number - screen position y
  */
  __New(automation, window, x, y) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.window := window
    this.x := x
    this.y := y
    RDA_Log_Debug(A_ThisFunc)
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "RDA_WindowPosition{win: " . this.window.toString() . ", x: " . this.x . ", y: " . this.y . "}"
  }
  /*!
    Method: clone
      Duplicates screen position

    Returns:
      <RDA_ScreenRegion>
  */
  clone() {
    return new RDA_WindowPosition(this.automation, this.window, this.x, this.y)
  }
  ; internal
  _checkValidWindow() {
    RDA_Assert(this.window.isAlive(), "Window is closed")
    RDA_Assert(this.window.isHidden(), "Window is hidden")

    ; it's valid, active!
    this.window.activate()
  }
  /*!
    Method: toScreen
      Changes current relative position to screen position

    Parameters:
      win - RDA_Window -window

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      windows := automation.windows()
      win := windows.findOne({"process": "xxx.exe"})
      winPos := new RDA_ScreenPosition(automation, 50, 50).relativeTo(win)
      screenPos := winPos.toScreen()
      ==========================

    Returns:
      <RDA_ScreenPosition>
  */
  toScreen() {
    local
    global RDA_ScreenPosition

    this._checkValidWindow()
    winPos := this.window.getPosition()

    return new RDA_ScreenPosition(this.automation, this.x + winPos.x, this.y + winPos.y)
  }


  ;
  ;
  ;
  /*!
    Method: getLength
      Calculates the length to origin

    Returns:
      number
  */
  getLength() {
    local

    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    v := Sqrt(screenX * screenX + screenY * screenY)
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
      Sets current window position

    Parameters:
      x - number - x coordinate
      y - number - y coordinate

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
      Adds given position

    Parameters:
      screenPos - <RDA_ScreenPosition>|<RDA_WindowPosition> - position

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
      Subtracts given position

    Parameters:
      screenPos - <RDA_ScreenPosition>|<RDA_WindowPosition> - position

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
    local

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    RDA_MouseMove(this.automation, 0, screenX, screenY)

    return this
  }
  /*!
    Method: click
      Alias of <RDA_AutomationMouse.click>

    Returns:
      <RDA_ScreenPosition>
  */
  click() {
    local

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    this.automation.mouse().click(screenX, screenY)

    return this
  }
  /*!
    Method: rightClick
      Alias of <RDA_AutomationMouse.rightClick>

    Returns:
      <RDA_ScreenPosition>
  */
  rightClick() {
    local

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    this.automation.mouse().rightClick(screenX, screenY)

    return this
  }
  /*!
    Method: doubleClick
      Alias of <RDA_AutomationMouse.doubleClick>

    Returns:
      <RDA_ScreenPosition>
  */
  doubleClick() {
    local

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    this.automation.mouse().doubleClick(screenX, screenY)

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
    local

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    return RDA_PixelGetColor(screenX, screenY)
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

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_PixelWaitAppearColor(color, screenX, screenY, timeout, delay)

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

    this._checkValidWindow()
    winPos := this.window.getPosition()
    screenX := this.x + winPos.x
    screenY := this.y + winPos.y

    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_PixelWaitDisappearColor(color, screenX, screenY, timeout, delay)

    return this
  }

}
