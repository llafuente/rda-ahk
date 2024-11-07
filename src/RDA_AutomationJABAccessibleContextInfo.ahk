/*!
  Class: RDA_AutomationJABAccessibleContextInfo
    Java Access Bridge element info
*/
class RDA_AutomationJABAccessibleContextInfo extends RDA_Base {
  /*!
    property: name
      the AccessibleName of the object
  */
  name := 0
  /*!
    property: description
      the AccessibleDescription of the object
  */
  description := 0
  /*!
    property: role
      localized AccessibleRole string
  */
  role := 0
  /*!
    property: states
      localized AccessibleStateSet string (comma separated)
  */
  states := 0
  /*!
    property: indexInParent
      index of object in parent, starts at zero
  */
  indexInParent := 0
  /*!
    property: childrenCount
      # of children, if any
  */
  childrenCount := 0
  /*!
    property: x
      screen x-axis co-ordinate in pixels
  */
  x := 0
  /*!
    property: y
      screen y-axis co-ordinate in pixels
  */
  y := 0
  /*!
    property: width
      pixel width of object
  */
  width := 0
  /*!
    property: height
      pixel height of object
  */
  height := 0
  /*!
    property: accessibleValueInterface
      bool, implement accessible value interface
  */
  accessibleValueInterface := 0
  /*!
    property: accessibleActionInterface
      bool, implement accessible action interface
  */
  accessibleActionInterface := 0
  /*!
    property: accessibleComponentInterface
      bool, implement accessible component interface
  */
  accessibleComponentInterface := 0
  /*!
    property: accessibleSelectionInterface
      bool, implement accessible selection interface
  */
  accessibleSelectionInterface := 0
  /*!
    property: accessibleTableInterface
      bool, implement accessible table interface
  */
  accessibleTableInterface := 0
  /*!
    property: accessibleTextInterface
      bool, implement accessible text interface
  */
  accessibleTextInterface := 0
  /*!
    property: name
      bool, implement accessible Hypertext interface
  */
  accessibleHypertextInterface := 0

  __New() {
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
