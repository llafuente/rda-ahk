class RDA_Position extends RDA_Base {
  /*!
    Method: checkColor
      Checks if current pixel colors in the sent variance range

    Example:
      ======= AutoHotKey =======
      automation := RDA_Automation()
      if (new RDA_ScreenPosition(automation, 50, 50).checkColor(0xFF0000)) {
        // do red magic!
      }
      ==========================

    Returns:
      boolean
  */
  checkColor(color, variation := 0) {
    local

    c := this.getColor()

    return RDA_Color_variantion(c, color) <= variation
  }
}
