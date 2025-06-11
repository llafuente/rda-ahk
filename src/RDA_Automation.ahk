/*!
  Class: RDA_Automation
    Automation configuration and the library entry point.
*/
class RDA_Automation extends RDA_Base {
  /*!
    Constant: TIMEOUT
      Default timeout, in miliseconds
  */
  static TIMEOUT := 60000

  /*!
    Constant: DELAY
      Default delay, in miliseconds
  */
  static DELAY := 250
  /*!
    Constant: HIGHLIGHT_TIME
      Default highlight time, in miliseconds
  */
  static HIGHLIGHT_TIME := 1000
  /*!
    Property: keyDelay
      number - Delay between key strokes, in milliseconds.

      Use -1 for no delay at all and 0 for the smallest possible delay

      See: https://www.autohotkey.com/docs/commands/SetKeyDelay.htm
  */
  keyDelay := 50
  /*!
    Property: pressDuration
      number - Certain games and other specialized applications may require a
      delay inside       each keystroke; that is, after the press of the key
      but before its release.

      Specify -1 for no delay at all or 0 for the smallest possible delay
      (however, if the Play parameter is present, both 0 and -1 produce no delay).

      See: https://www.autohotkey.com/docs/commands/SetKeyDelay.htm
  */
  pressDuration := -1
  /*!
    Property: mouseDelay
      number - Delay between mouse strokes.

      Time in milliseconds.

      Specify -1 for no delay at all or 0 for the smallest possible delay

      See: https://www.autohotkey.com/docs/v1/lib/SetMouseDelay.htm
  */
  mouseDelay := 50
  /*!
    Property: inputMode
      string - Configures how input is going to be sent

      Valid values:

      * interactive

      * background (non-interactive)
  */
  inputMode := "interactive"
  /*!
    Property: sendMode
      string - Makes Send synonymous with SendInput or SendPlay rather than the
      default (SendEvent). Also makes Click and MouseMove/Click/Drag use the
      specified method.

      Valid values:

      * Event (*default*)

      * Input

      * InputThenPlay

      * Play

      See: https://www.autohotkey.com/docs/commands/SendMode.htm
  */
  sendMode := "Event"
  /*!
    Constant: sendModes
      string[] - <RDA_Automation.sendMode> Validation list.
  */
  static sendModes := ["Event", "Input", "InputThenPlay", "Play"]
  /*!
    Property: actionDelay
      number - Delay after each action performed by the library.

      This value allows you to adapt to performance degrade in long running
      applications and also helps you to slow down a bot to debug.
  */
  actionDelay := 100
  /*!
    Property: mouseSpeed
      number - Default mouse movement speed

      See: https://www.autohotkey.com/docs/v1/lib/MouseMove.htm
  */
  mouseSpeed := 2
  /*!
    Property: blockInputInteractive
      boolean - Blocks user input on interactive inputMode ?
  */
  blockInputInteractive := true
  /*!
    Property: blockInputBackground
      boolean - Blocks user input on background inputMode ?
  */
  blockInputBackground := false
  /*!
    Property: imageSearchSensibility
      number - Default image search sensibility. See "*n (variation)" at https://www.autohotkey.com/docs/v1/lib/ImageSearch.htm#Parameters
  */
  imageSearchSensibility := 4

  ; internal
  _UIA := 0
  /*!
    Property: UIA
      <RDA_AutomationUIA> - Microsoft UI Automation (lazy initialization)
  */
  UIA [] {
    get {
      if (!this._UIA) {
        RDA_Log_Info("Initialize UIA")
        this._UIA := UIA_Interface()
      }

      return this._UIA
    }
  }

  ; internal
  _JAB := 0
  /*!
    Property: JAB
      <RDA_AutomationJAB> - Java acess bridge (lazy initialization)
  */
  JAB [] {
    get {
      if (!this._JAB) {
        RDA_Log_Info("Initialize JAB")
        this._JAB := new RDA_AutomationJAB(this)
      }
      return this._JAB
    }
  }

  /*!
    Property: limits
      <RDA_SearchLimits> - Define Search/Dump limits
  */
  limits := new RDA_SearchLimits()

  /*!
    Constructor:
      Configures <RDA_Automation>

    Parameters:
      inputMode - number - see <RDA_Automation.inputMode>
      keyDelay - number - see <RDA_Automation.keyDelay>
      pressDuration - number - see <RDA_Automation.pressDuration>
      actionDelay - number - see <RDA_Automation.actionDelay>
      sendMode - number - see <RDA_Automation.sendMode>
      mouseDelay - number - see <RDA_Automation.mouseDelay>
      mouseSpeed - number - see <RDA_Automation.mouseSpeed>
  */
  __New(inputMode := "interactive", actionDelay := 100, keyDelay := 50, pressDuration := -1, sendMode := "Event", mouseDelay := 50, mouseSpeed := 2) {
    this.setInputMode(inputMode)
    this.setActionDelay(actionDelay)
    this.setKeyDelay(keyDelay)
    this.setPressDuration(pressDuration)
    this.setSendMode(sendMode)
    this.setMouseDelay(mouseDelay)
    this.setMouseSpeed(mouseSpeed)
  }

  __Delete() {
    local
    RDA_Log_Info(A_ThisFunc)
    if (this._UIA) {
      RDA_Log_Debug(A_ThisFunc . " RemoveAllEventHandlers()")
      try {
        this._UIA.RemoveAllEventHandlers()
      } catch e {
        RDA_Log_Error(A_ThisFunc . " " . e.message)
      }
    }

    this._UIA := 0
    this._JAB := 0
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "RDA_Automation{inputMode: " . this.inputMode . ", actionDelay: " . this.actionDelay . ", keyDelay: " . this.keyDelay . ", pressDuration: " . this.pressDuration . ", sendMode: " . this.sendMode . ", mouseDelay: " . this.mouseDelay . ", mouseSpeed: " . this.mouseSpeed ", UIA: " . (this.UIA ? "yes" : "no") . ", imageSearchSensibility: " . this.imageSearchSensibility . "}"
  }
  /*!
    Method: setKeyDelay
      Sets the delay that will occur after each keystroke sent by Send or ControlSend.

    Parameters:
      keyDelay - number - see <RDA_Automation.keyDelay>
  */
  setKeyDelay(keyDelay) {
    RDA_Log_Debug(A_ThisFunc . "(" . keyDelay . ")")
    this.keyDelay := keyDelay
  }
  /*!
    Method: setInputMode
      Sets the how input will be sent

    Parameters:
      inputMode - number - see <RDA_Automation.inputMode>
  */
  setInputMode(inputMode) {
    RDA_Log_Debug(A_ThisFunc . "(" . inputMode . ")")
    if (inputMode != "interactive" && inputMode != "background") {
      throw RDA_Exception("Invalid value: " . inputMode)
    }
    this.inputMode := inputMode
  }
  /*!
    Method: setActionDelay
      Sets how much time we wait after performing an action: SendKeys/Click

    Parameters:
      actionDelay - number - see <RDA_Automation.actionDelay>
  */
  setActionDelay(actionDelay) {
    RDA_Log_Debug(A_ThisFunc . "(" . actionDelay . ")")
    this.actionDelay := actionDelay
  }
  /*!
    Method: setSendMode
      Makes Send synonymous with SendInput or SendPlay rather than the default (SendEvent).
      Also makes Click and MouseMove/Click/Drag use the specified method.

    Parameters:
      sendMode - number - see <RDA_Automation.sendMode>
  */
  setSendMode(sendMode) {
    RDA_Log_Debug(A_ThisFunc . "(" . sendMode . ")")
    /*
    if (sendMode == "InputThenPlay") {
      throw RDA_Exception("Invalid mode: InputThenPlay is forbidden")
    }
    if (sendMode == "Play") {
      throw RDA_Exception("Invalid mode: Play is forbidden")
    }
    */
    if (!RDA_Array_IndexOf(RDA_Automation.sendModes, sendMode)) {
      throw RDA_Exception("Invalid mode: " . sendMode)
    }
    this.sendMode := sendMode
  }
  /*!
    Method: setPressDuration
      Sets press duration.

    Parameters:
      pressDuration - number - see <RDA_Automation.pressDuration>
  */
  setPressDuration(pressDuration) {
    RDA_Log_Debug(A_ThisFunc . "(" . pressDuration . ")")
    this.pressDuration := pressDuration
  }
  /*!
    Method: setMouseDelay
      Sets mouse delay.

    Parameters:
      mouseDelay - number - see <RDA_Automation.mouseDelay>
  */
  setMouseDelay(mouseDelay) {
    RDA_Log_Debug(A_ThisFunc . "(" . mouseDelay . ")")
    this.mouseDelay := mouseDelay
  }
  /*!
    Method: setMouseSpeed
      Sets mouse speed.

    Parameters:
      mouseSpeed - number - see <RDA_Automation.mouseSpeed>
  */
  setMouseSpeed(mouseSpeed) {
    RDA_Log_Debug(A_ThisFunc . "(" . mouseSpeed . ")")
    this.mouseSpeed := mouseSpeed
  }
  /*!
    Method: setBlockInput
      Confifures BlockInput per inputMode

    Parameters:
      mouseSpeed - number - see <RDA_Automation.mouseSpeed>
  */
  setBlockInput(interactive, background) {
    RDA_Log_Debug(A_ThisFunc . "(" . (interactive ? "yes" : "no") . ", " . (background ? "yes" : "no") . ")")
    this.blockInputInteractive := !!interactive
    this.blockInputBackground := !!background
  }
  /*!
    Method: setImageSearchSensibility
      Confifures default image search sensibility

    Parameters:
      imageSearchSensibility - number - see <RDA_Automation.imageSearchSensibility>
  */
  setImageSearchSensibility(imageSearchSensibility) {
    this.imageSearchSensibility := imageSearchSensibility
  }

  /*!
    Method: windows
      Get operations over Windows at OS level

    Returns:
      <RDA_AutomationWindows>
  */
  windows() {
    return new RDA_AutomationWindows(this)
  }
  /*!
    Method: windownFromHWND
      Creates an <RDA_AutomationWindow> given a window handle

    Returns:
      <RDA_AutomationWindows>
  */
  windownFromHWND(hwnd) {
    return new RDA_AutomationWindow(this, hwnd)
  }
  /*!
    Method: mouse
      Get operations over Mouse at OS level

    Returns:
      <RDA_AutomationMouse>
  */
  mouse() {
    return new RDA_AutomationMouse(this)
  }
  /*!
    Method: keyboard
      Get operations over Keyboard at OS level

    Returns:
      <RDA_AutomationKeyboard>
  */
  keyboard() {
    return new RDA_AutomationKeyboard(this)
  }
  /*!
    Method: pixel
      Create a <RDA_ScreenPosition> at given x,y

    Parameters:
      x - number - screen position x
      y - number - screen position y

    Returns:
      <RDA_ScreenPosition>
  */
  pixel(x, y) {
    return new RDA_ScreenPosition(this, x, y)
  }
  /*!
    Method: clipboard
      Get operations over Clipboard at OS level

    Returns:
      <RDA_AutomationClipboard>
  */
  clipboard() {
    return new RDA_AutomationClipboard(this)
  }
  /*!
    Method: screen
      Retrieves a region with the given screen

    Parameter:
      idx - number - screen index, starting at 1

    Returns:
      <RDA_ScreenRegion>
  */
  screen(idx) {
    ; https://learn.microsoft.com/en-us/windows/win32/gdi/multiple-display-monitors-functions
    if (idx != 1) {
      ; TODO
      throw RDA_Exception("Not implemented")
    }
    return RDA_ScreenRegion.fromPoints(this, 0, 0, A_ScreenWidth, A_ScreenHeight)
  }

  /*!
    Method: region
      Creates a region

    Parameter:
      x - number - x coordinate
      y - number - y coordinate
      w - number - width (default means same as window)
      h - number - height (default means same as window)

    Returns:
      <RDA_ScreenRegion>
  */
  region(x, y, width, height) {
    return RDA_ScreenRegion.fromPoints(this, x, y, width, height)
  }

  /*!
    Method: monitors
      Creates <RDA_Monitors>

    Returns:
      <RDA_Monitors>
  */
  monitors() {
    return new RDA_Monitors(this)
  }
  /*!
    Method: virtualDesktops
      Creates <RDA_VirtualDesktops>

    Returns:
      <RDA_VirtualDesktops>
  */
  virtualDesktops() {
    return new RDA_VirtualDesktops(this)
  }
  /*!
    Method: requestBlockInput
      Request to block user input

    Parameters:
      honorInputMode - boolean - Honor input mode or just block

    Returns:
      <RDA_Automation>
  */
  requestBlockInput(honorInputMode := true) {
    if ((!honorInputMode)
        || (this.inputMode == "interactive" && this.blockInputInteractive)
        || (this.inputMode == "background" && this.blockInputBackground)) {

      if (!A_IsAdmin) {
        RDA_Log_Debug(A_ThisFunc . " user is not admin, it may not work")
      } else {
        RDA_Log_Debug(A_ThisFunc)
      }
      RDA_BlockInput("On")
    }

    return this
  }
  /*!
    Method: releaseBlockInput
      Release user input blockage

    Parameters:
      honorInputMode - boolean - Honor input mode or just block

    Returns:
      <RDA_Automation>
  */
  releaseBlockInput(honorInputMode := true) {
    if ((!honorInputMode)
        || (this.inputMode == "interactive" && this.blockInputInteractive)
        || (this.inputMode == "background" && this.blockInputBackground)) {
      RDA_Log_Debug(A_ThisFunc)
      RDA_BlockInput("Off")
    }
  }
}
