/*!
  class: RDA_SearchLimits
    Configure search/dump limits. If the limit is execeeded it wil be logged
*/
class RDA_SearchLimits {
  /*!
    property: maxChildren
      number - If an element has more than maxChildren, do not follow

      This will be ignored if it's the element that starts the search.
  */
  maxChildren := 500
  /*!
    property: maxElements
      number - If we have already process maxElements, do not follow children
  */
  maxElements := 1000
  /*!
    property: maxDepth
      number - Once reached this depth, stop
  */
  maxDepth := 32
  /*!
    property: skipChildrenOfTypes
      string[] - Skip children of element with this type.

      This will be ignored if it's the element that starts the search.
  */
  skipChildrenOfTypes := []
  /*!
    constructor:RDA_SearchLimits

    parameters:
      maxChildren - number - See <RDA_SearchLimits.maxChildren>
      maxElements - number - See <RDA_SearchLimits.maxElements>
      maxDepth - number - See <RDA_SearchLimits.maxDepth>
      skipChildrenOfTypes - string[] - See <RDA_SearchLimits.skipChildrenOfTypes>
  */
  __New(maxChildren := 500, maxElements := 1000, maxDepth := 32, skipChildrenOfTypes := 0) {
      this.maxChildren := maxChildren
      this.maxElements := maxElements
      this.maxDepth := maxDepth
      this.skipChildrenOfTypes := skipChildrenOfTypes ? skipChildrenOfTypes : []
  }

  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_SearchLimits{maxChildren: " . this.maxChildren . ", maxElements: " . this.maxElements . ", maxDepth: " . this.maxDepth . ", skipChildrenOfTypes: " . RDA_JSON_stringify(this.skipChildrenOfTypes) . "}"
  }

  /*!
    Method: reset
      Restore defaults values
  */
  reset() {
      this.maxChildren := 500
      this.maxElements := 100
      this.maxDepth := 32
      this.skipChildrenOfTypes := []
  }
}



