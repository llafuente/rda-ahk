/*!
  Class: RDA_Rectangle
    Represents a rectangle (w,h)
*/
class RDA_Rectangle extends RDA_Base {
  /*!
    Property: automation
      <RDA_Automation>
  */
  automation := 0
  /*!
    Property: w
      number - width
  */
  w := 0
  /*!
    Property: h
      number - height
  */
  h := 0
  /*!
    Constructor: RDA_Rectangle
      Creates a rectangle

    Parameters:
      automation - <RDA_Automation> - automation config
      w - number - width
      h - number - height
  */
  __New(automation, w, h) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
    this.w := w
    this.h := h
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_Rectangle{w: " . this.w . ", h: " . this.h . "}"
  }
  /*!
    Method: clone
      Duplicates rectangle

    Returns:
      <RDA_Rectangle>
  */
  clone() {
    return new RDA_Rectangle(this.automation, this.w, this.h)
  }
}
