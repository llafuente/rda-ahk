/*!
  class: RDA_AutomationBaseElement
    Implements basic logic for element handling that apply to JAB and UIA
*/
class RDA_AutomationBaseElement extends RDA_Base {
  /*!
    Method: hasPattern
      Checks if current element implements given pattern

    Parameters:
      pattern - string - pattern

    Returns:
      bool
  */
  hasPattern(pattern) {
    local

    v := RDA_Array_IndexOf(this.getPatterns(), pattern) > 0
    RDA_Log_Debug(A_ThisFunc "(" . pattern . ") = " . (v ? "yes" : "no"))

    return v
  }
  ;
  ; xpath
  ;
  ; internal
  xpathGetValue(access) {
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(access) . ")")

    switch (access.type) {
      case "literal": {
        return access.literal
      }
      case "identifier": {
        switch (Format("{:U}", access.identifier)) {
          case "@DESCRIPTION":
            return this.getDescription()
          case "@TYPE":
            return this.getType()
          case "@NAME":
            return this.getName()
          case "@IDX":
            return this.getIndex()
          case "@INDEX":
            return this.getIndex()
          default:
            throw RDA_Exception("Unkown identifier: " . access.identifier)
        }
      }
      default:
        throw RDA_Exception("Unkown type: " . access.type)
    }
  }
  ; internal
  xpathLogicalAnd(left, right) {
    local r, l, ret := []
    RDA_Log_Debug(A_ThisFunc)
    l := this.xPathExecuteAction(left, this)
    r := this.xPathExecuteAction(right, this)

    loop % l.length() {
      litem := l[A_Index]
      loop % r.length() {
        ritem := r[A_Index]
        if (litem.isSameElement(ritem)) {
          ret.push(litem)
          break
        }
      }
    }

    return ret
  }
  ; internal
  xpathLogicalOr(left, right) {
    local r, l, ret := [], found
    RDA_Log_Debug(A_ThisFunc)
    l := this.xPathExecuteAction(left, this)
    r := this.xPathExecuteAction(right, this)

    ; start with left then add those in right that are not in left
    ret := l
    loop % r.length() {
      ritem := r[A_Index]
      found := false
      loop % l.length() {
        litem := l[A_Index]
        if (litem.isSameElement(ritem)) {
          found := true
          break
        }
      }
      if (!found) {
        ret.push(ritem)
      }
    }

    return ret
  }
  ; internal
  xPathFilterMatch(left, right) {
    RDA_Log_Debug(A_ThisFunc)
    ; TODO case sensitive ?
    return this.xpathGetValue(left) == this.xpathGetValue(right) ? [this] : []
  }
  ; internal
  xpathFilterNotMatch(left, right) {
    RDA_Log_Debug(A_ThisFunc)
    ; TODO case sensitive ?
    return this.xpathGetValue(left) != this.xpathGetValue(right) ? [this] : []
  }
  ; internal
  xPathExecuteAction(action, item) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(action) ", " . item.toString() . ")")

    switch (action.action) {
      case "getDescendants":
        return item.getDescendants()
      case "getChildren":
        return item.getChildren()
      case "xpathLogicalAnd":
        return item.xpathLogicalAnd(action.arguments[1], action.arguments[2])
      case "xpathLogicalOr":
        return item.xpathLogicalOr(action.arguments[1], action.arguments[2])
      case "xPathFilterMatch":
        return item.xPathFilterMatch(action.arguments[1], action.arguments[2])
      case "xpathFilterNotMatch":
        return item.xpathFilterNotMatch(action.arguments[1], action.arguments[2])
      default:
        throw RDA_Exception("Unkown action: " . action.action)
    }
/*
    if (!item.HasKey(action.action)) {
      RDA_Log_Debug(item)
      throw RDA_Exception("Method not found: " . action.action)
    }

    if (action.arguments) {
      args := RDA_Array_Concat([item], action.arguments)
      return ObjBindMethod(item, action.action, args*).call()
    }

    return ObjBindMethod(item, action.action).call()
*/
  }
  ; internal, to cache xpath
  _find(actions) {
    local
    global RDA_Log_Level

    ; startTime := A_TickCount
    RDA_Log_Level := 2
    stack := [this]
    try {
      loop % actions.length() {
        ; startTime2 := A_TickCount

        RDA_Log_Debug(A_ThisFunc . " executing Action " . A_Index . " stack " . stack.length())
        action := actions[A_Index]
        nstack := []
        while (stack.length()) {
          RDA_Log_Debug(A_ThisFunc . " stack " . stack.length())
          newItems := this.xPathExecuteAction(action, stack.pop())
          RDA_Log_Debug(A_ThisFunc . " newItems " . newItems.length())
          nstack := RDA_Array_Concat(nstack, newItems)
        }
        stack := nstack
        ; RDA_Log_Info(A_ThisFunc . " executed Action " . A_Index . " stack " . stack.length() . " elapsed = " . (A_TickCount - startTime2))
      }
      RDA_Log_Level := 3
    } catch e {
      RDA_Log_Level := 3
      RDA_Log_Error(A_ThisFunc . " " . e.message)
      throw e
    }
    ; RDA_Log_Info(A_ThisFunc . " elapsed = " . (A_TickCount - startTime))
    return stack
  }

  /*!
    Method: find
      Retrieves all elements that match given query

    Parameters:
      query - string - xpath-ish

  Example:
    ======= AutoHotKey =======
    ; Returns all List with name xxx
    elements := element.find("//List[@name = 'xxx']")
    ; search all list and returns label children
    elements := element.find("//List/Label")
    ; Returns all nodes with type document or edit
    elements := element.find("//*[@type = 'Document' or @type = 'Edit']")
    ; Returns Labels under a list
    elements := element.find("//List/Label")
    ==========================

    Throws:
      Not found

    Returns:
      <RDA_AutomationUIAElement>
  */
  find(query) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . query . ")")

    actions := RDA_xPath_Parse(query)
    elements := this._find(actions)

    if (!elements.length()) {
      RDA_Log_Error(A_ThisFunc . " Not found at " . this.toString())
      throw RDA_Exception("Not found: " . query)
    }

    RDA_Log_Debug(A_ThisFunc . " Found " . elements.length() . " elements")
    return elements
  }

  /*!
    Method: findOne
      Retrieves the first element that match given query

    Parameters:
      query - string - xpath-ish

    Throws:
      Element not found
      Multiple elements found

    Returns:
      <RDA_AutomationUIAElement>
  */
  findOne(query) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . query . ")")

    actions := RDA_xPath_Parse(query)
    elements := this._find(actions)

    if (!elements.length()) {
      RDA_Log_Error(A_ThisFunc . " Not found at " . this.toString())
      throw RDA_Exception("Not found: " . query)
    }

    if (elements.length() > 1) {
      throw RDA_Exception("Multiple elements found: " . query)
    }

    return elements[1]
  }
  /*!
    Method: waitOne
      Waits to appear an element that match given query

    Parameters:
      query - string - xpath-ish
      timeout - number - timeout, in miliseconds
      delay - number - delay, in miliseconds

    Throws:
      Timeout reached at ?: Control not found

    Returns:
      <RDA_AutomationUIAElement>
  */
  waitOne(query, timeout := -1, delay := -1) {
    local startTime := A_TickCount, actions, elements
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)

    RDA_Log_Debug(A_ThisFunc . "(" . query . ", " . timeout . ", " . delay . ")")

    actions := RDA_xPath_Parse(query)

    loop {
      elements := this._find(actions)
      if (elements.length() == 1) {
        return elements[1]
      }

      if (A_TickCount >= startTime + timeout) {
        RDA_Log_Error(A_ThisFunc " timeout(" . timeout . ") reached")
        if (elements.length() == 0) {
          throw RDA_Exception("Timeout reached at " . A_ThisFunc . ": Control not found: " . xpath)
        }
        throw RDA_Exception("Timeout reached at " . A_ThisFunc . ": Multiple elements found: " . xpath)
      }

      sleep % delay
    }
  }
  ;
  ; actions
  ;


  ;
  ; query
  ;
  /*!
    Method: dumpXML
      Dumps element tree as XML

    Returns:
      string - the dump
  */
  dumpXML() {
    local
    RDA_Log_Debug(A_ThisFunc)

    root := this.__dumpTree()
    r := this.__dumpNodeTree(root[1])

    return r
  }
  ; internal
  __dumpTree() {
    local

    RDA_Log_Debug(A_ThisFunc)

    dump := []
    elements := []

    elements.push({offset: 1, index: "", node: this, target: dump, path: ""})

    while(elements.length() > 0) {
      element := elements.pop()

      try {
        dumpNode := {name: element.node.getName()
          , type: element.node.getType()
          , patterns: RDA_Array_Join(element.node.getPatterns(), ",")
          , children: []
          , path: !element.index ? "" :  (element.path . "/" . element.index) }

        ; TODO how to check in UIA that there is description!?
        try {
          dumpNode.description := element.node.getDescription()
        } catch e {
          ;RDA_Log_Error(A_ThisFunc . " getDescription -> " . e.message)
        }
        if (element.node.hasPattern("SelectionItem")) {
          dumpNode.selected := element.node.isSelected()
        }
        if (element.node.hasPattern("Value")) {
          dumpNode.value := element.node.getValue()
          RDA_Log_Debug("value" . dumpNode.value)
        }

        element.target.push(dumpNode)
        children := element.node.getChildren()

        loop % children.length() {
          elements.InsertAt(1, {offset: element.offset + 1
            , index: A_Index
            , path: dumpNode.path
            , node: children[A_Index]
            , target: dumpNode.children})
        }
      } catch e {
        RDA_Log_Debug(A_ThisFunc . " " . e.message)
      }
    }

    ; RDA_Log_Debug(RDA_JSON_stringify(dump, , "  "))
    return dump
  }
  ; internal
  __dumpNodeTree(node, padding := "") {
    local

    text := ""
    ; name, type, patterns, children, path
    text .= padding . "<" . node.type . " name=" . RDA_JSON_stringify(node.name) . " patterns=" . RDA_JSON_stringify(node.patterns) . " path=" . RDA_JSON_stringify(node.path) . " description=" . RDA_JSON_stringify(node.description)
    if (node.haskey("value")) {
      text .= " value=" . RDA_JSON_stringify(node.value)
    }
    if (node.haskey("selected")) {
      text .= " selected=" . (node.selected ? """yes""" : """no""")
    }
    text .= ">`n"
    loop % node.children.length() {
      text .= this.__dumpNodeTree(node.children[A_Index], padding . "  ")
    }
    text .= padding .  "</" . node.type . ">`n"

    return text
  }


}
