/*!
  Class: RDA_AutomationMouse
*/
class RDA_AutomationMouse extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationMouse)

  automation := 0

  /*!
    Constructor:

    Parameters:
      automation - <RDA_Automation>
  */
  __New(automation) {
    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: click
      Performs a left click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  click(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "LEFT", 1, x, y)

    return this
  }
  /*!
    Method: rightClick
      Performs a right click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  rightClick(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "RIGHT", 1, x, y)

    return this
  }
  /*!
    Method: rightClick
      Performs a lft double click at given position.

      See <RDA_Mouse_ScreenClick>

    Parameters:
      x - number - x screen position (9999 will click current position)
      y - number - y screen position (9999 will click current position)

    Returns:
      <RDA_AutomationMouse>
  */
  doubleClick(x := 9999, y := 9999) {
    RDA_Mouse_ScreenClick(this.automation, "LEFT", 2, x, y)

    return this
  }
  /*!
    Method: move
      See <RDA_MouseRelativeMove>

    Returns:
      <RDA_AutomationMouse>
  */
  move(x, y) {
    RDA_MouseRelativeMove(this.automation, x, y)

    return this
  }
  /*!
    Method: move
      See <RDA_MouseMove>

    Returns:
      <RDA_AutomationMouse>
  */
  moveTo(x, y) {
    RDA_MouseMove(this.automation, 0, x, y)

    return this
  }
  /*!
    Method: move
      See <RDA_MouseGetPosition>

    Returns:
      <RDA_ScreenPosition>
  */
  get() {
    return RDA_MouseGetPosition(this.automation)
  }
}
