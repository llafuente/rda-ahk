/*!
  Class: RDA_WindowRegion

  Extends: RDA_Region
*/
class RDA_WindowRegion extends RDA_Region {
  /*!
    Property: origin
      <RDA_AutomationWindow> - window
  */
  window := 0
  /*!
    Construtor: RDA_WindowRegion

    Parameters:
      window - <RDA_AutomationWindow>
      origin - <RDA_ScreenPosition> - screen position x
      rect - <RDA_Rectangle> - screen position y
  */
  __New(window, origin, rect) {

    this.window := window

    this.origin := origin
    this.rect := rect

    RDA_Assert(this.window, A_ThisFunc . " window is null")
  }
  /*
    Static: fromPoints
      Creates a <RDA_WindowRegion> from points

    Parameters:
      automation - <RDA_AutomationWindow> - win
      x - number - x coordinate
      y - number - y coordinate
      w - number - width (default means same as window)
      h - number - height (default means same as window)

    Returns:
      <RDA_WindowRegion>
  */
  fromPoints(win, x, y, w, h) {
    return new RDA_WindowRegion(win, new RDA_ScreenPosition(win.automation, x, y), new RDA_Rectangle(win.automation, w, h))
  }
  /*
    Static: fromWin32Rect
      Creates a <RDA_ScreenRegion> from a Win32 RECT pointer

    Parameters:
      win - <RDA_AutomationWindow> - window
      ptr - pointer - Memory address
      offset - number - Offset

    Returns:
      <RDA_ScreenRegion>
  */
  fromWin32Rect(win, ptr, offset := 0) {
    return RDA_ScreenRegion.fromPoints(win
      , NumGet(ptr + 0, 0 + offset, "Int")
      , NumGet(ptr + 0, 4 + offset, "Int")
      , NumGet(ptr + 0, 8 + offset, "Int")
      , NumGet(ptr + 0, 12 + offset, "Int"))
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_WindowRegion{win: " . this.window.toString() . ", x: " . this.origin.x . ", y: " . this.origin.y . ", w: " . this.rect.w . ", h: " . this.rect.h . "}"
  }
  /*!
    Method: clone
      Duplicates region

    Returns:
      <RDA_ScreenRegion>
  */
  clone() {
    return new RDA_WindowRegion(this.window, this.origin.clone(), this.rect.clone())
  }

  ; internal
  _checkValidWindow() {
    RDA_Assert(this.window.isAlive(), "Window is closed")
    RDA_Assert(this.window.isHidden(), "Window is hidden")

    ; it's valid, active!
    ; TODO handle background?!
    this.window.activate()

    return this.window
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
      winPos := new RDA_WindowRegion(automation, 50, 50).relativeTo(win)
      screenPos := winPos.toScreen()
      ==========================

    Returns:
      <RDA_ScreenRegion>
  */
  toScreen() {
    local
    global RDA_ScreenRegion

    this._checkValidWindow()
    winPos := this.window.getPosition()

    return new RDA_ScreenRegion(this.origin.clone().add(winPos), this.rect.clone())
  }


  ;
  ; box model
  ;

  /*!
    Method: getCenter
      Calculates the center of the region

    Returns:
      <RDA_WindowPosition>
  */
  getCenter() {
    local x := this.origin.x + (this.rect.w // 2)
    local y := this.origin.y + (this.rect.h // 2)

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
  /*!
    Method: getTopLeft
      Retrieves the screen position of the top left corner

    Returns:
      <RDA_WindowPosition>
  */
  getTopLeft() {
    local x := this.origin.x
    local y := this.origin.y

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
  /*!
    Method: getTopRight
      Retrieves the screen position of the top right corner

    Returns:
      <RDA_WindowPosition>
  */
  getTopRight() {
    local x := this.origin.x + this.rect.w
    local y := this.origin.y

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
  /*!
    Method: getBottomLeft
      Retrieves the screen position of the bottom left corner

    Returns:
      <RDA_WindowPosition>
  */
  getBottomLeft() {
    local x := this.origin.x
    local y := this.origin.y + this.rect.h

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
  /*!
    Method: getBottomRight
      Retrieves the screen position of the bottom right corner

    Returns:
      <RDA_WindowPosition>
  */
  getBottomRight() {
    local x := this.origin.x + this.rect.w
    local y := this.origin.y + this.rect.h

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
  /*!
    Method: getRandom
      Retrieves a random screen position inside the region

    Returns:
      <RDA_WindowPosition>
  */
  getRandom() {
    local
    global RDA_WindowPosition
    Random, wRand , 0, 10000
    Random, hRand , 0, 10000

    x := this.origin.x + (this.rect.w * wRand / 10000)
    y := this.origin.y + (this.rect.h * hRand / 10000)

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_WindowPosition(this.window, x, y)
  }
}
