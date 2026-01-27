/*!
  Class: RDA_AutomationJABAccessibleContextInfo
    Java Access Bridge element info
*/
class RDA_AutomationJABAccessibleContextInfo extends RDA_Base {
  /*!
    Property: window
      <RDA_AutomationWindow> - window instance
  */
  window := 0
  /*!
    Property: name
      string - the AccessibleName of the object
  */
  name := 0
  /*!
    Property: description
      string - the AccessibleDescription of the object
  */
  description := 0
  /*!
    Property: role
      string - localized AccessibleRole string
  */
  role := 0
  /*!
    Property: states
      string - localized AccessibleStateSet string (comma separated)
  */
  states := 0
  /*!
    Property: indexInParent
      number - current index in parent, starts at zero
  */
  indexInParent := 0
  /*!
    Property: childrenCount
      number - number of children, if any
  */
  childrenCount := 0
  /*!
    Property: x
      number - screen x-axis co-ordinate in pixels
  */
  x := 0
  /*!
    Property: y
      number - screen y-axis co-ordinate in pixels
  */
  y := 0
  /*!
    Property: width
      number - pixel width of object
  */
  width := 0
  /*!
    Property: height
      number - pixel height of object
  */
  height := 0
  /*!
    Property: accessibleValueInterface
      bool - implement accessible value interface
  */
  accessibleValueInterface := 0
  /*!
    Property: accessibleActionInterface
      bool - implement accessible action interface
  */
  accessibleActionInterface := 0
  /*!
    Property: accessibleComponentInterface
      bool - implement accessible component interface
  */
  accessibleComponentInterface := 0
  /*!
    Property: accessibleSelectionInterface
      bool - implement accessible selection interface
  */
  accessibleSelectionInterface := 0
  /*!
    Property: accessibleTableInterface
      bool - implement accessible table interface
  */
  accessibleTableInterface := 0
  /*!
    Property: accessibleTextInterface
      bool - implement accessible text interface
  */
  accessibleTextInterface := 0
  /*!
    Property: name
      bool - implement accessible Hypertext interface
  */
  accessibleHypertextInterface := 0

  ; internal: cache
  _region := 0

  /*!
    Property: region
      <RDA_WindowRegion>
  */
  region [] {
    get {
      local
      global RDA_WindowRegion

      if (!this._region) {
        winPos := this.window.getPosition()
        this._region := RDA_WindowRegion.fromPoints(this.window, this.x - winPos.x, this.y - winPos.y, this.width, this.height)
      }

      ; RDA_Log_Debug(A_ThisFunc . " " . this._region.toString())
      return this._region
    }
  }

  /*!
    Constructor: RDA_AutomationJABAccessibleContextInfo
      Creates RDA_AutomationJABAccessibleContextInfo

    Parameters:
      win - <RDA_AutomationWindow> - window
  */
  __New(win) {
    this.window := win

    RDA_Assert(this.window, "invalid argument win is empty")
    RDA_Assert(RDA_instaceOf(this.window, RDA_AutomationWindow), "expected win to be instance of RDA_AutomationWindow")

    this.sealed := true
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    local

    interfaces := []

    if (this.accessibleActionInterface) {
      interfaces.push("Action")
    }
    if (this.accessibleValueInterface) {
      interfaces.push("Value")
    }
    if (this.accessibleComponentInterface) {
      interfaces.push("Component")
    }
    if (this.accessibleSelectionInterface) {
      interfaces.push("Selection")
    }
    if (this.accessibleTableInterface) {
      interfaces.push("Table")
    }
    if (this.accessibleTextInterface) {
      interfaces.push("Text")
    }
    if (this.accessibleHypertextInterface) {
      interfaces.push("Hypertext")
    }

    return "`nname = " . this.name
      . "`ndescription = " . this.description
      . "`nrole = " . this.role
      . "`nstates = " . this.states
      . "`nindexInParent = " . this.indexInParent
      . "`nchildrenCount = " . this.childrenCount
      . "`nregion = (" . this.x . ", " . this.y . ", " . this.width . ", " . this.height . ")"
      . "`nInterfaces = " . RDA_Array_Join(interfaces, ",")
  }
}
