class Test_RDA_XPath {
  Begin() {
  }



  Test_15_Automation_XPath() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    automation := new RDA_Automation("background")

    lastException := 0
    try {
      _RDA_xPath_Tokenize("/Button[@Name=""Close]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Unclosed string literal", "double Unclosed string literal")

    lastException := 0
    try {
      _RDA_xPath_Tokenize("/Button[@Name='Close]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Unclosed string literal", "single Unclosed string literal")

    lastException := 0
    try {
      RDA_xPath_Parse("x")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Query shall start with slash", "Query shall start with slash 1")

    lastException := 0
    try {
      RDA_xPath_Parse("+")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Query shall start with slash", "Query shall start with slash 2")

    lastException := 0
    try {
      RDA_xPath_Parse("//Button[@Name = 'pepe'")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Unclosed brace found", "Unclosed brace found 1")

    lastException := 0
    try {
      RDA_xPath_Parse("//Button[@Name = 'pepe']/Text[")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Unclosed brace found", "Unclosed brace found 2")


    lastException := 0
    try {
      RDA_xPath_Parse("/Button[@Name!=""Close"" and @idx =]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Requested to parse and expression but not enought tokens found", "parse error expr")

    lastException := 0
    try {
      RDA_xPath_Parse("/Button[@Name!=""Close"" @idx]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Expected a logical operator", "parse error expr")

    lastException := 0
    try {
      RDA_xPath_Parse("/Button[= 7 8]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Left hand side must be an identifier or literal", "parse error expr")

    lastException := 0
    try {
      RDA_xPath_Parse("/Button[7 7 8]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "After identifier or literal must be an operator", "parse error expr")

    lastException := 0
    try {
      RDA_xPath_Parse("/Button[7 = =]")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Right hand side must be an identifier or literal", "parse error expr")


    lastException := 0
    try {
      RDA_xPath_Parse("[")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Query shall start with slash", "Query shall start with slash 3")



    actions := RDA_xPath_Parse("//*")
    Yunit.assert(actions.length() == 1, "1 actions 1")
    Yunit.assert(actions[1].action == "getDescendants", "1 actions.action")

    actions := RDA_xPath_Parse("/*")
    Yunit.assert(actions.length() == 1, "2 actions 1")
    Yunit.assert(actions[1].action == "getChildren", "2 actions.action")


    tokens := _RDA_xPath_Tokenize("/Button[@Name=""Close""]")
    Yunit.assert(tokens.length() == 7, "1. 7 tokens")

    actions := _RDA_xPath_Parse(tokens)
    Yunit.assert(actions.length() == 3, "1. 2 actions 1")
    Yunit.assert(actions[1].action == "getChildren", "1. 1 getChildren")
    Yunit.assert(actions[2].action == "xpathFilterMatch", "1. 2 filterMatch")
    Yunit.assert(actions[3].action == "xpathFilterMatch", "1. 3 filterMatch")


    {
      tokens := _RDA_xPath_Tokenize("//Button[@Name!=""abc/ll=""]")
      Yunit.assert(tokens.length() == 8, "2. 7 tokens")

      actions := _RDA_xPath_Parse(tokens)
      Yunit.assert(actions.length() == 3, "2. 2 actions 1")
      Yunit.assert(actions[1].action == "getDescendants", "2. 1st getDescendants")
      Yunit.assert(actions[2].action == "xpathFilterMatch", "2. 2nd filterMatch")
      Yunit.assert(actions[3].action == "xpathFilterNotMatch", "2. 3rd filterNotMatch")
    }

    ; hacks
    ; get the third button with name close
    {
      tokens := _RDA_xPath_Tokenize("/Button[@Name!=""Close"" and @idx = 3]")
      Yunit.assert(tokens.length() == 11, "3. 7 tokens")

      actions := _RDA_xPath_Parse(tokens)
      Yunit.assert(actions.length() == 3, "3. 2 actions 1")
      Yunit.assert(actions[1].action == "getChildren", "3. 1st getChildren")
      Yunit.assert(actions[2].action == "xpathFilterMatch", "3. 2nd filterMatch")
      Yunit.assert(actions[3].action == "xpathLogicalAnd", "3. 3rd  xpathLogicalAnd")
      Yunit.assert(actions[3].arguments[1].action == "xpathFilterNotMatch", "3. 3rd.left filterNotMatch")
      Yunit.assert(actions[3].arguments[2].action == "xpathFilterMatch", "3. 3rd.right filterNotMatch")
    }
    {
      tokens := _RDA_xPath_Tokenize("/Button[@Name!=""Close"" or @idx = 3]")
      Yunit.assert(tokens.length() == 11, "4. 7 tokens")

      actions := _RDA_xPath_Parse(tokens)
      Yunit.assert(actions.length() == 3, "4. 2 actions 1")
      Yunit.assert(actions[1].action == "getChildren", "4. 1st getChildren")
      Yunit.assert(actions[2].action == "xpathFilterMatch", "4. 2nd filterMatch")
      Yunit.assert(actions[3].action == "xpathLogicalOr", "4. 3rd  xpathLogicalOr")
      Yunit.assert(actions[3].arguments[1].action == "xpathFilterNotMatch", "4. 3rd.left filterNotMatch")
      Yunit.assert(actions[3].arguments[2].action == "xpathFilterMatch", "4. 3rd.right filterNotMatch")
    }
    {
      tokens := _RDA_xPath_Tokenize("//*[@Name=""12\"" x 18\"""" and @Type=""ListItem""]")
      Yunit.assert(tokens.length() == 12, "5. 12 tokens")
      Yunit.assert(tokens[7].literal == "12"" x 18""", "5. 7th token is escaped")

      actions := _RDA_xPath_Parse(tokens)
    }

;
;  xpath := "//Button[matches(@Name, ""\d+"")]/Text"
;  xpathObj := { "recurse": true,
;    , tests: [{attribute: "Name", operation: "matches", value: "\d+"}
;            , {attribute: "Type", operation: "equals", value: "Button"}]}
;    , child: {"recurse": true, Type: "Text"
;      , tests: []}}
;

  }

  End() {
  }
}
