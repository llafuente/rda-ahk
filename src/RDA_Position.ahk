/*!
  Class: RDA_Position
    Base class to represent a position in 2D
*/
class RDA_Position extends RDA_Base {
  /*!
    Method: equal
      Equality check

    Parameters:
      other - <RDA_Position> - x coordinate

    Returns:
      <RDA_Position>
  */
  equal(other) {
    RDA_Log_Debug(A_ThisFunc . "(" . other.toString() . ") == " . this.toString())
    a := this.toScreen()
    b := other.toScreen()
    return a.x == b.x && a.y == b.y
  }
  /*!
    Method: equal2
      Equality check

    Parameters:
      x - number - x coordinate
      y - number - x coordinate

    Returns:
      <RDA_Position>
  */
  equal2(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . ", " . y . ") == " . this.toString())
    return this.x == x && this.y == y
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
    Method: set2
      Sets current position

    Parameters:
      x - number - x amount
      y - number - y amount

    Returns:
      <RDA_Position>
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
      pos - <RDA_Position> - position

    Returns:
      <RDA_Position>
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
      <RDA_Position>
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
      pos - <RDA_Position> - position

    Returns:
      <RDA_Position>
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
      <RDA_Position>
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

    Parameters:
      color - number - RGB Color
      variation - number - Allowed color variation, default: expect match

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

    Parameters:
      color - number - RGB Color
      variation - number - Allowed color variation, default: expect match
      expectionMessage - string - exception message. Tokens:

      * %readcolor%

      * %expectedColor%

      * %expectedVariantion%

    Throws
      default: Expected color [%readcolor%] to be [%expectedColor%] (±%expectedVariantion%)"

    Returns:
      <RDA_Position>
  */
  expectColor(color, variation := 0, expectionMessage := -1) {
    local

    c := this.getColor()
    expectionMessage := expectionMessage == -1 ? "Expected color [%readcolor%] to be [%expectedColor%] (±%expectedVariantion%)" : expectionMessage

    if (RDA_Color_variantion(c, color) > variation) {
      expectionMessage := StrReplace(expectionMessage, "%readcolor%", c)
      expectionMessage := StrReplace(expectionMessage, "%expectedColor%", color)
      expectionMessage := StrReplace(expectionMessage, "%expectedVariantion%", variation)

      throw RDA_Exception(expectionMessage)
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
      <RDA_Position> - for chaining
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
      <RDA_Position> - for chaining
  */
  drawBorder(overlay, color, radius := 1, size := 1) {
    overlay.borderCircle(this.toScreen(), color, radius, size)

    return this
  }
}
