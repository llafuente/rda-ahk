/*!
  class: RDA_ElementTreeNode
*/
class RDA_ElementTreeNode {
  /*!
    Property: element
    <RDA_AutomationJABElement> | <RDA_AutomationUIAElement> - current element
  */
  element := 0
  /*!
    Property: children
    <RDA_AutomationJABElement>[] | <RDA_AutomationUIAElement>[] - children list
  */
  children := 0
  /*!
    Property: depth
      number - current depth in the tree (ancestry)
  */
  depth := 0
  /*!
    Property: path
      string - path to current element using indexes
  */
  path := ""

  /*!
    static: flattern
      Flatterns the tree

    Parameters:
      node - <RDA_AutomationJABElement> | <RDA_AutomationUIAElement>
    Returns:
      <RDA_AutomationJABElement>[] | <RDA_AutomationUIAElement>[]
  */
  flattern(node, ret := 0) {
    if (!ret) {
      ret := []
    }

    ret.push(node)

    loop % node.children.length() {
      RDA_ElementTreeNode.flattern(node.children[A_Index], ret)
    }

    return ret
  }
}
