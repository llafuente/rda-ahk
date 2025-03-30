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
  set(x, y) {
    RDA_Log_Debug(A_ThisFunc . "(" . x . "," . y . ")")

    this.x := x
    this.y := y

    return this
  }
  /*!
    Method: move
      Moves (add XY) to current position. See <RDA_Position.add>

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
    Method: add
      Adds given screen position

    Parameters:
      pos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  add(pos) {
    this.x += pos.x
    this.y += pos.y

    return this
  }
  /*!
    Method: subtract
      Subtracts given screen position

    Parameters:
      pos - <RDA_ScreenPosition> - screen position

    Returns:
      <RDA_ScreenPosition>
  */
  subtract(pos) {
    this.x -= pos.x
    this.y -= pos.y

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
      If color dont match

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
}
