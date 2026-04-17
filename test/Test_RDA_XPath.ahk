test_RDA_xPath_Parse_error(xpath, expected_message) {
  global Yunit

  lastException := 0
  try {
    RDA_xPath_Parse(xpath)
  } catch e {
    lastException := e
  }
  expected_message := expected_message . "`nparsing: " . xpath
  Yunit.assert(lastException.message == expected_message, RDA_JSON_stringify(lastException.message) . " != " . RDA_JSON_stringify(expected_message))
}

class Test_RDA_XPath {
  Begin() {
  }

  __parse_error(xpath, message) {
    local
    global Yunit

    RDA_Log_Debug(A_ThisFunc . "(" . xpath . ", " . message . ")")

    lastException := 0
    try {
      RDA_xPath_Parse(xpath)
    } catch e {
      lastException := e
    }
    RDA_Log_Debug(lastException.message)
    Yunit.assert(InStr(lastException.message, message) == 1, "exception thrown: " . message)
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

    test_RDA_xPath_Parse_error("x", "Query shall start with slash or dot")
    test_RDA_xPath_Parse_error("+", "Query shall start with slash or dot")
    test_RDA_xPath_Parse_error("//Button[@Name = 'pepe'", "Unclosed brace found")
    test_RDA_xPath_Parse_error("//Button[@Name = 'pepe']/Text[", "Unclosed brace found")
    test_RDA_xPath_Parse_error("/""button""", "Index literal shall be a number")
    test_RDA_xPath_Parse_error("/Button[@Name!=""Close"" and @idx =]", "Requested to parse and expression but not enought tokens found")
    test_RDA_xPath_Parse_error("/Button[@Name!=""Close"" @idx]", "Expected a logical operator")
    test_RDA_xPath_Parse_error("/Button[= 7 8]", "Left hand side must be an identifier or literal")
    test_RDA_xPath_Parse_error("/Button[7 7 8]", "After identifier or literal must be an operator")
    test_RDA_xPath_Parse_error("/Button[7 = =]", "Right hand side must be an identifier or literal")
    test_RDA_xPath_Parse_error("[", "Query shall start with slash or dot")

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

    ;actions := RDA_xPath_Parse("//Label/..")
    actions := RDA_xPath_Parse("./*[@value=""xxx""]")
    Yunit.assert(actions.length() == 2, "1 actions 1")
    Yunit.assert(actions[1].action == "getCurrent", "./ 1st action")
    Yunit.assert(actions[2].action == "xpathFilterMatch", "./ 2nd action")

    actions := RDA_xPath_Parse(".//")

    actions := RDA_xPath_Parse(".//")
    Yunit.assert(actions[1].action == "getDescendants", ".// -> getDescendants")
    actions := RDA_xPath_Parse("./")
    Yunit.assert(actions[1].action == "getCurrent", "./ -> getCurrent")
    actions := RDA_xPath_Parse("/")
    Yunit.assert(actions[1].action == "getChildren", "/ -> getChildren")
    actions := RDA_xPath_Parse("//")
    Yunit.assert(actions[1].action == "getDescendants", ".// -> getDescendants")
    actions := RDA_xPath_Parse("/..")
    Yunit.assert(actions[1].action == "getParent", "/.. -> getParent")
    actions := RDA_xPath_Parse("./..")
    Yunit.assert(actions[1].action == "getCurrent", "./..[1] -> getParent")
    Yunit.assert(actions[2].action == "getParent", "./..[2] -> getParent")

    actions := RDA_xPath_Parse("./*[@value=""xxx""]/..")
    Yunit.assert(actions.length() == 3, "3 actions")
    Yunit.assert(actions[3].action == "getParent", "./ 2nd action")
    RDA_Log_Debug(actions)



    this.__parse_error("/Button[starts-with(@value, ""xxx""]","Could not find close parenthesis")
    this.__parse_error("/Button[starts-with(@value]","Could not find close parenthesis")
    this.__parse_error("/Button[@value , ""xxx""]","unexpected comma operator position")
    this.__parse_error("/Button[@value(""xxx"",)]", "unexpected comma operator position")


    actions := RDA_xPath_Parse("/Button[starts-with()]")
    RDA_Log_Debug(actions)
    Yunit.assert(actions[3].action == "call", " 3rd action is a call")
    Yunit.assert(actions[3].name == "RDA_XPath_fn_starts_with", " 3rd action is a call to: RDA_XPath_fn_starts_with")
    Yunit.assert(actions[3].arguments.length() == 0, "3rd action is a call with no arguments")


    actions := RDA_xPath_Parse("/Button[starts-with(@value)]")
    RDA_Log_Debug(actions)
    Yunit.assert(actions[3].action == "call", " 3rd action is a call")
    Yunit.assert(actions[3].name == "RDA_XPath_fn_starts_with", " 3rd action is a call to: RDA_XPath_fn_starts_with")
    Yunit.assert(actions[3].arguments.length() == 1, "3rd action is a call with 1 argument")
    Yunit.assert(actions[3].arguments[1].identifier == "@value", "3rd action 1st argument: @value")

    actions := RDA_xPath_Parse("/Button[starts-with(@value, @value)]")
    RDA_Log_Debug(actions)
    Yunit.assert(actions[3].action == "call", "3rd action is a call")
    Yunit.assert(actions[3].name == "RDA_XPath_fn_starts_with", "3rd action is a call to: RDA_XPath_fn_starts_with")
    Yunit.assert(actions[3].arguments.length() == 2, "3rd action is a call with 2 argument")
    Yunit.assert(actions[3].arguments[1].identifier == "@value", "3rd action 1st argument: @value")
    Yunit.assert(actions[3].arguments[2].identifier == "@value", "3rd action 2nd argument: @value")




    actions := RDA_xPath_Parse("/Button[starts-with(@value, @value, ""xxx"")]")
    RDA_Log_Debug(actions)
    Yunit.assert(actions.length() == 3, "3 actions")
    Yunit.assert(actions[3].action == "call", "3rd action is a call")
    Yunit.assert(actions[3].name == "RDA_XPath_fn_starts_with", "3rd action is a call to: RDA_XPath_fn_starts_with")
    Yunit.assert(actions[3].arguments.length() == 3, "3rd action is a call with 3 argument")
    Yunit.assert(actions[3].arguments[1].identifier == "@value", "3rd action 1st argument: @value")
    Yunit.assert(actions[3].arguments[2].identifier == "@value", "3rd action 2nd argument: @value")
    Yunit.assert(actions[3].arguments[3].literal == "xxx", "3rd action 2nd argument: @value")


    ; recursive
    actions := RDA_xPath_Parse("/Button[a(b(), c(d()))]")
    RDA_Log_Debug(actions)
    Yunit.assert(actions.length() == 3, "3 actions")
    Yunit.assert(actions[3].action == "call", "3rd action is a call")
    Yunit.assert(actions[3].name == "RDA_XPath_fn_a", "call a")
    Yunit.assert(actions[3].arguments[1].name == "RDA_XPath_fn_b", "call a(b")
    Yunit.assert(actions[3].arguments[2].name == "RDA_XPath_fn_c", "call a(b,c")
    Yunit.assert(actions[3].arguments[2].arguments[1].name == "RDA_XPath_fn_d", "call a(b,c(d")
  }

  End() {
  }
}
