/*!
  class: RDA_AutomationKeyboard
    Keyboard handling at OS level.

  Remarks:
    type use Raw Mode
*/
class RDA_AutomationKeyboard extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationKeyboard)

  automation := 0

  __New(automation) {
    RDA_Assert(!automation, A_ThisFunc . " automation is null")
    this.automation := automation
  }
  /*!
    Method: type
      Sends given text (literally) as keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Remarks:
      use Raw mode: https://www.autohotkey.com/docs/v1/lib/Send.htm#Raw

    Parameters:
      text - string - Text

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  type(text) {
    RDA_Log_Debug(A_ThisFunc . "(text = " . text . ") " . this.automation.toString())
    RDA_KeyboardSendKeys(this.automation, this.hwnd, "{Raw}" . text)

    return this
  }
  /*!
    Method: typePassword
      Sends given password (literally) as keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Remarks:
      use Raw mode: https://www.autohotkey.com/docs/v1/lib/Send.htm#Raw

    Parameters:
      text - string - Text

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  typePassword(password) {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ") " . this.automation.toString())
    RDA_KeyboardSendKeys(this.automation, this.hwnd, "{Raw}" . password)

    return this
  }
  /*!
    Method: sendKeys
      Sends simulated keystrokes

      See: <RDA_KeyboardSendKeys>

    Remarks:
      This method can disclosure information, use <RDA_AutomationKeyboard.sendPassword>

    Parameters:
      keys - string of keys

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  sendKeys(keys) {
    RDA_Log_Debug(A_ThisFunc . "(keys = " . keys . ") " . this.automation.toString())
    RDA_KeyboardSendKeys(this.automation, 0, keys)

    return this
  }
  /*!
    Method: sendPassword
      It's an alias of <RDA_AutomationKeyboard.sendKeys> but just log the length

      See: <RDA_KeyboardSendKeys>

    Parameters:
      password - password string

    Throws:
      hwnd is required in background input mode

    Returns:
      <RDA_AutomationKeyboard>
  */
  sendPassword(password) {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ") " . this.automation.toString())
    RDA_KeyboardSendKeys(this.automation, 0, password)

    return this
  }
}
