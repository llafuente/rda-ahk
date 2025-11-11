/*!
  Class: RDA_ScreenRegion
    Represents a region (x,y,w,h) in the screen

  Extends: RDA_Region
*/
class RDA_ScreenRegion extends RDA_Region {
  __New(origin, rect) {
    this.origin := origin
    this.rect := rect

    RDA_Log_Debug(A_ThisFunc . " " . this.toString())
  }
  /*
    Static: fromPoints
      Creates a <RDA_ScreenRegion> from points

    Parameters:
      automation - <RDA_Automation> - automation
      x - number - x coordinate
      y - number - y coordinate
      w - number - width (default means same as window)
      h - number - height (default means same as window)

    Returns:
      <RDA_ScreenRegion>
  */
  fromPoints(automation, x, y, w, h) {
    return new RDA_ScreenRegion(new RDA_ScreenPosition(automation, x, y), new RDA_Rectangle(automation, w, h))
  }
  /*
    Static: fromWin32Rect
      Creates a <RDA_ScreenRegion> from a Win32 RECT pointer

    Parameters:
      automation - <RDA_Automation> - automation
      ptr - pointer - Memory address
      offset - number - Offset

    Returns:
      <RDA_ScreenRegion>
  */
  fromWin32Rect(automation, ptr, offset := 0) {
    return RDA_ScreenRegion.fromPoints(automation
      , NumGet(ptr + 0, 0 + offset, "Int")
      , NumGet(ptr + 0, 4 + offset, "Int")
      , NumGet(ptr + 0, 8 + offset, "Int")
      , NumGet(ptr + 0, 12 + offset, "Int"))
  }
  /*
    Static: fromPrimaryScreen
      Creates a <RDA_ScreenRegion> from primary screen

    Parameters:
      automation - <RDA_Automation> - automation

    Returns:
      <RDA_ScreenRegion>
  */
  fromPrimaryScreen(automation) {
    RDA_Log_Debug(A_ThisFunc)

    return new RDA_ScreenRegion(new RDA_ScreenPosition(automation, 0, 0), new RDA_Rectangle(automation, A_ScreenWidth, A_ScreenHeight))
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_ScreenRegion{x: " . this.origin.x . ", y: " . this.origin.y . ", w: " . this.rect.w . ", h: " . this.rect.h . "}"
  }
  /*!
    Method: clone
      Duplicates region

    Returns:
      <RDA_ScreenRegion>
  */
  clone() {
    return new RDA_ScreenRegion(this.origin.clone(), this.rect.clone())
  }

  ;
  ; box model
  ;

  /*!
    Method: getCenter
      Calculates the center of the region

    Returns:
      <RDA_ScreenPosition>
  */
  getCenter() {
    local x := this.origin.x + (this.rect.w // 2)
    local y := this.origin.y + (this.rect.h // 2)

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }
  /*!
    Method: getTopLeft
      Retrieves the screen position of the top left corner

    Returns:
      <RDA_ScreenPosition>
  */
  getTopLeft() {
    local x := this.origin.x
    local y := this.origin.y

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }
  /*!
    Method: getTopRight
      Retrieves the screen position of the top right corner

    Returns:
      <RDA_ScreenPosition>
  */
  getTopRight() {
    local x := this.origin.x + this.rect.w
    local y := this.origin.y

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }
  /*!
    Method: getBottomLeft
      Retrieves the screen position of the bottom left corner

    Returns:
      <RDA_ScreenPosition>
  */
  getBottomLeft() {
    local x := this.origin.x
    local y := this.origin.y + this.rect.h

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }
  /*!
    Method: getBottomRight
      Retrieves the screen position of the bottom right corner

    Returns:
      <RDA_ScreenPosition>
  */
  getBottomRight() {
    local x := this.origin.x + this.rect.w
    local y := this.origin.y + this.rect.h

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }
  /*!
    Method: getRandom
      Retrieves a random screen position inside the region

    Returns:
      <RDA_ScreenPosition>
  */
  getRandom() {
    local
    global RDA_ScreenPosition
    Random, wRand , 0, 10000
    Random, hRand , 0, 10000

    x := this.origin.x + (this.rect.w * wRand / 10000)
    y := this.origin.y + (this.rect.h * hRand / 10000)

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }

  ;
  ; debug
  ;

  /*!
    Method: highlight
      Highlights current region

    Parameters:
      displayTime - number - miliseconds
      color - string - color
      d - number - outline width

    Returns:
      <RDA_ScreenRegion>
  */
  highlight(displayTime:=-1, color:="Red", d:=4) {
    local
    global RDA_Automation

    RDA_Log_Debug(A_ThisFunc . "(" . this.toString() . ")")
    displayTime := displayTime == -1 ? RDA_Automation.HIGHLIGHT_TIME : displayTime

    x := this.origin.x
    y := this.origin.y
    w := this.rect.w
    h := this.rect.h
    d:=Floor(d)

    Loop 4 {
      Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
      i:=A_Index
      , x1:=(i=2 ? x+w : this.origin.x-d)
      , y1:=(i=3 ? y+h : y-d)
      , w1:=(i=1 or i=3 ? w+2*d : d)
      , h1:=(i=2 or i=4 ? h+2*d : d)
      Gui, Range_%i%: Color, %color%
      Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
    }
    Sleep, %displayTime%
    Loop 4
      Gui, Range_%A_Index%: Destroy

    return this
  }

  ; internal to avoid code duplication :)
  toScreen() {
    return this
  }

}
