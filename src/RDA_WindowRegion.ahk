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
    Property: origin
      <RDA_ScreenPosition> - origin of the region
  */
  origin := 0
  /*!
    Property: rect
      <RDA_Rectangle> - size of the region
  */
  rect := 0
  /*!
    Property: x
      number - Getter shortcut to origin.x
  */
  x[] {
    get {
      return this.origin.x
    }
  }
  /*!
    Property: y
      number - Getter shortcut to origin.y
  */
  y[] {
    get {
      return this.origin.y
    }
  }
  /*!
    Property: w
      number - Getter shortcut to rect.w
  */
  w[] {
    get {
      return this.rect.w
    }
  }
  /*!
    Property: h
      number - Getter shortcut to rect.w
  */
  h[] {
    get {
      return this.rect.h
    }
  }
  /*!
    Construtor: RDA_WindowRegion

    Parameters:
      automation - <RDA_Automation>
      origin - <RDA_ScreenPosition> - screen position x
      rect - <RDA_Rectangle> - screen position y
  */
  __New(window, origin, rect) {

    this.window := window

    this.origin := origin
    this.rect := rect

    RDA_Assert(this.window, A_ThisFunc . " automation is null")
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
}
