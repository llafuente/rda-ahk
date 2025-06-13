/*
    typedef struct AccessibleTableInfoTag {
        JOBJECT64 caption;  // AccesibleContext
        JOBJECT64 summary;  // AccessibleContext
        jint rowCount;
        jint columnCount;
        JOBJECT64 accessibleContext;
        JOBJECT64 accessibleTable;
    } AccessibleTableInfo;
*/

/*!
  Class: RDA_AutomationJABAccessibleContextInfo
    Java Access Bridge table info
*/
class RDA_AutomationJABAccessibleTableInfo extends RDA_Base {
  /*!
    property: caption
      <RDA_AutomationJABElement> - caption
  */
  caption := 0
  /*!
    property: summary
      <RDA_AutomationJABElement> - summary
  */
  summary := 0
  /*!
    property: rowCount
      number - row count
  */
  rowCount := 0
  /*!
    property: columnCount
      number - row count
  */
  columnCount := 0
  /*!
    property: accessibleContext
      <RDA_AutomationJABElement> - accessibleContext
  */
  accessibleContext := 0
  /*!
    property: accessibleTable
      <RDA_AutomationJABElement> - accessibleTable
  */
  accessibleTable := 0

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

    return "{rows: " . this.rowCount . ", columns: " . this.columnCount . "}"
  }
}
