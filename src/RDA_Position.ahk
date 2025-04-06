/*!
  Class: RDA_Position
*/
class RDA_Position extends RDA_Base {
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
    Method: set
      Sets current position

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_ScreenPosition>
  */
  set2(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ")")

    this.x := x
    this.y := y

    return this
  }
  /*!
    Method: add
      Adds given amount

    Parameters:
      pos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  add(pos) {
    RDA_Log_Debug(A_ThisFunc . "(" . pos.toString() . ")")

    this.x += pos.x
    this.y += pos.y

    return this
  }
  /*!
    Method: add2
      Adds given amount

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_ScreenPosition>
  */
  add2(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ")")

    this.x += x
    this.y += y

    return this
  }
  /*!
    Method: subtract
      Subtracts given amount

    Parameters:
      pos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  subtract(pos) {
    RDA_Log_Debug(A_ThisFunc . "(" . pos.toString() . ")")

    this.x -= pos.x
    this.y -= pos.y

    return this
  }
  /*!
    Method: subtract
      Subtracts given amount

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_ScreenPosition>
  */
  subtract2(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . pos.toString() . ")")

    this.x -= x
    this.y -= y

    return this
  }
  /*!
    Method: isColor
      Checks if current pixel colors in the sent variance range

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      if (new RDA_ScreenPosition(automation, 50, 50).isColor(0xFF0000)) {
        // do red magic!
      }
      ==========================

    Returns:
      boolean
  */
  isColor(color, variation := 0) {
    local

    c := this.getColor()

    return (variation == 0 ? c == color : (RDA_Color_variantion(c, color) <= variation))
  }
  /*!
    Method: expectColor
      Checks if current pixel colors in the sent variance range

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      win := automation.windows().findOne({...})
      win.pixel(50, 50).expectColor(0xFF0000)
      ==========================

    Throws
      If color does not match

    Returns:
      <RDA_Position>
  */
  expectColor(color, variation := 0) {
    c := this.getColor()

    if (RDA_Color_variantion(c, color) > variation) {
      throw RDA_Exception("Expected color [" . c . "] to be: " . color . "(±" . variation . ")")
    }

    return this
  }
  ;
  ; overlay draw
  ;
  /*!
    Method: drawFill
      Draws a colored dot (circle)

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius

    Returns:
      <RDA_ScreenPosition> - for chaining
  */
  drawFill(overlay, color, radius := 1) {
    overlay.fillCircle(this.toScreen(), color, radius)

    return this
  }

  /*!
    Method: drawBorder
      Draws a bordered circle

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius

    Returns:
      <RDA_ScreenPosition> - for chaining
  */
  drawBorder(overlay, color, radius := 1, size := 1) {
    overlay.borderCircle(this.toScreen(), color, radius, size)

    return this
  }
}
