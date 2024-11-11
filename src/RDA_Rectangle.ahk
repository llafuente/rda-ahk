/*!
  class: RDA_Rectangle
    Represents a rectangle (w,h)
*/
class RDA_Rectangle extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_Rectangle)

  automation := 0
  w := 0
  h := 0

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
}
