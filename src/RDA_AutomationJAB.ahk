/*!
  class: RDA_AutomationJAB
    Automation configuration for java access bridge.

  Remarks:
    After an action (most probably: click or doAction) and dialog opens and
    any JAB call fails.

    The source of the error is that the main thread is block waiting the dialog
    to close.

    The workaround is to click at OS Level so JAB won't be blocked at the same
    time that the background window.

  Remarks:
    Some operations do not modify the UI.

    Some UI elements requires user interaction to refresh, for example a
    combobox. The solution is to use a combinarion os OS Level operations and
    JAB Operations.

    For example:

    ======= AutoHotKey =======
    ; get all popup
    jabWin := win.asJABElement()

    jabWin.findOne("//ComboBox").osClick()
    jabWin.findOne("//Label[@name=""option 1""]").select()
    win.sendKeys("{ENTER}")
    ==========================

  Remarks:
    JAB is unable to set slider values.
*/
class RDA_AutomationJAB extends RDA_Base {
  ; internal
  static JABSWITCH_ENABLED := 0
  /*!
    Constant: MAX_BUFFER_SIZE
      number - max buffer size
  */
  static MAX_BUFFER_SIZE := 10240
  /*!
    Constant: MAX_STRING_SIZE
      number - max string size
  */
  static MAX_STRING_SIZE := 1024
  /*!
    Constant: SHORT_STRING_SIZE
      number - short string size
  */
  static SHORT_STRING_SIZE := 256
  /*!
    Property: automation
      <RDA_Automation>
  */
  automation := 0
  /*!
    Property: javaPath
      Path to java.exe
  */
  javaPath := ""
  /*!
    Property: acpType
      Accessible Context pointer type
  */
  acpType := 0
  /*!
    Property: acpType
      Accessible Context type
  */
  acType := 0
  /*!
    Property: acSize
      Accessible Context size
  */
  acSize := 0
  /*!
    Property: dllName
      DLL Name
  */
  dllName := 0
  /*!
    Property: isInitialized
      is JAB initialized ?
  */
  isInitialized [] {
    get {
      return RDA_AutomationJAB.JABSWITCH_ENABLED > 0
    }
  }

  ; internal, LoadLibrary result
  library := 0

  /*!
    Constructor: RDA_AutomationJAB
      Internal, use <RDA_Automation.JAB>

    Parameter:
      automation - <RDA_Automation> -
  */
  __New(automation) {
    this.automation := automation
    RDA_Assert(this.automation, "invalid argument automation is empty")
  }
  /*!
    Method: init
      Starts jabswitch so JavaAccessBridge can be used and initialize.

      It's recommended to call it before starts the java application.

    Parameter:
      java_path - string - Path to java.exe
  */
  init(java_path) {
    local
    global RDA_AutomationJAB

    RDA_Log_Debug(A_ThisFunc . "(" . java_path . ")")
    this.javaPath := java_path
    jabswitch := this.javaPath . "\jabswitch.exe"

    if (!FileExist(jabswitch)) {
      throw RDA_Exception(jabswitch . " not found at provided java_path")
    }

    if (RDA_AutomationJAB.JABSWITCH_ENABLED == 0) {
      this.__jabswitch(this.javaPath, "disable")
      this.__jabswitch(this.javaPath, "enable")
    }

    RDA_AutomationJAB.JABSWITCH_ENABLED += 1

    if (A_PtrSize=8) {
      this.acType :="Int64"
      this.acpType := "Int64*"
      this.acSize := 8

      this.dllName := "WindowsAccessBridge-64"
      dllFile := this.javaPath . "\" . this.dllName . ".dll"
      RDA_Log_Debug(A_ThisFunc " LoadLibrary: " . dllFile)
      this.library := DllCall("LoadLibrary", "Str", dllFile)
    } else {
      RDA_Log_Debug(A_ThisFunc . " loading 32 bit")
      this.acType :="Int"
      this.acpType := "Int*"
      this.acSize :=4

      this.dllName :="WindowsAccessBridge-32"
      dllFile := this.javaPath . "\" . this.dllName . ".dll"
      RDA_Log_Debug(A_ThisFunc " LoadLibrary: " . dllFile)
      this.library := DllCall("LoadLibrary", "Str", dllFile)

      if (!this.library) {
        this.dllName :="WindowsAccessBridge"
        dllFile := this.javaPath . "\" . this.dllName . ".dll"
        RDA_Log_Debug(A_ThisFunc " LoadLibrary: " . dllFile)
        this.library := DllCall("LoadLibrary", "Str", dllFile)
      }
    }

    RDA_Assert(this.dllName, "dllName not set")
    RDA_Assert(this.library, "Could not load WindowsAccessBridge dll")

    ; initializeAccessBridge
    initialised := DllCall(this.dllName . "\Windows_run", "Cdecl Int")
    ; this time ensure that JAB has enough time to start before user
    ; starts an application
    Sleep, 250

    RDA_Log_Debug(A_ThisFunc . " JABInitialised? = " . initialised . " @ " . this.dllName)
    RDA_Assert(initialised, "Windows_run failed: Could not initialise WindowsAccessBridge dll")
  }

  __Delete() {
    RDA_Log_Info(A_ThisFunc . " JABSWITCH? " . RDA_AutomationJAB.JABSWITCH_ENABLED)

    RDA_Log_Debug(A_ThisFunc . " shutdown = " . DllCall(this.dllName . "\shutdownAccessBridge", "Cdecl Int"))

    DllCall("FreeLibrary", "Ptr", this.library)
    this.library := 0

    RDA_AutomationJAB.JABSWITCH_ENABLED -= 1
    if (!RDA_AutomationJAB.JABSWITCH_ENABLED) {
      this.__jabswitch(this.javaPath, "disable")
    }
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "RDA_AutomationJab{javaPath: " . this.javaPath . "}"
  }
  ; internal
  __jabswitch(java_path, state) {
    local

    shell := ComObjCreate("WScript.Shell")
    shell.CurrentDirectory := java_path
    process := shell.Exec(A_ComSpec . " /C jabswitch.exe -" . state)
    RDA_Log_Debug(A_ThisFunc . " " . state . " exitCode = " . process.Status)
    RDA_Log_Debug(process.StdOut.ReadAll())
    ; TODO: the magic Status can be checked!?
    if (process.Status != 0) {
      RDA_Log_Debug(process.StdErr.ReadAll())
      ;throw RDA_Exception("jabswitch.exe -" . state . " failed")
    }
  }
  ; internal
  _ensureInit() {
    if (!this.library) {
      throw RDA_Exception("JavaAccessBridge is not initilizated, call RDA_AutomationJAB.init()")
    }
  }
  /*!
    Method: isJavaWindow
      Checks to see if the given window implements the Java Accessibility API.

    Parameters:
      hwnd - number - Window handler

    Returns:
     boolean
  */
  isJavaWindow(hwnd) {
    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")
    return DllCall(this.dllName . "\isJavaWindow"
      , "Int", hwnd
      , "Cdecl Int")
  }
  /*!
    Method: elementFromHandle
      Gets the Root element of given window handle or throws

    Parameters:
      hwnd - number - Window handler

    Throws:
      JavaAccessBridge is not initilizated, call RDA_AutomationJAB.init()
      isJavaWindow failed
      getAccessibleContextFromHWND failed

    Returns:
     <RDA_AutomationJABElement>
  */
  elementFromHandle(hwnd) {
    local vmId := 0, acId := 0

    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")
    this._ensureInit()

    if (!this.isJavaWindow(hwnd)) {
      throw RDA_Exception("isJavaWindow failed")
    }

    if (!DllCall(this.dllName . "\getAccessibleContextFromHWND"
      , "Int", hwnd, "Int*", vmId, this.acpType, acId
      , "Cdecl " . this.acType)) {
      throw RDA_Exception("getAccessibleContextFromHWND failed")
    }

    RDA_Log_Debug(A_ThisFunc . " <-- vmId = " . vmId . ", acId = " . acId)

    return new RDA_AutomationJABElement(this, new RDA_AutomationWindow(this.automation, hwnd), vmId, acId)
  }
  /*!
    Method: windowFromElement
      Retrieve window handle from given element

    Remarks:
      This function may fail with acIds from callbacks (ex: <RDA_AutomationJAB.onClick>)

      The only work around is to use global variables to save current window.

    Parameters:
      vmID - number - Virtual machine handle
      acId - number - AccesibleContext handle

    Throws:
      Cannot not determine hwnd

    Returns:
      <RDA_AutomationWindow>
  */
  windowFromElement(vmID, acId) {
    local
    global RDA_AutomationWindow

    RDA_Log_Debug(A_ThisFunc . "(" . vmID . ", " . acId . ")")

    hwnd := DllCall(this.dllName . "\getHWNDFromAccessibleContext"
      , "Int", vmID
      , this.acType, acId
      , "Cdecl Ptr")

    RDA_Log_Debug(A_ThisFunc . " <-- " . hwnd)

    if (!hwnd) {
      throw RDA_Exception("Cannot not determine hwnd")
    }

    return new RDA_AutomationWindow(this.automation, hwnd)
  }
  /*!
    Method: getFocusedElement
      Get focused Element

    Parameters:
      hwnd - number - Window handler

    Throws:
      JavaAccessBridge is not initilizated, call RDA_AutomationJAB.init()

    Returns:
      <RDA_AutomationJABElement>
  */
  getFocusedElement(hwnd) {
    local vmId := 0, acId := 0

    RDA_Log_Debug(A_ThisFunc . "(" . hwnd . ")")
    this._ensureInit()

    DllCall(this.dllName . "\getAccessibleContextWithFocus"
      , "Int", hwnd, "Int*", vmId, this.acpType, acId
      , "Cdecl " . this.acType)

    return new RDA_AutomationJABElement(this, new RDA_AutomationWindow(this.automation, hwnd), vmId, acId)
  }
  /*!
    Method: getElementAt
      Retrieves an AccessibleContext object of the window or object that is under the mouse pointer.

    Parameters:
      win - <RDA_AutomationWindow> - window
      x - number - x window coordinate
      y - number - y window coordinate

    Throws:
      getAccessibleContextAt failed
      Element not found
  */
  getElementAt(win, x, y) {
    local
    global RDA_AutomationJABElement

    RDA_Log_Debug(A_ThisFunc . "(" . win.toString() . ", " . x . ", " . y . ")")

    element := this.elementFromHandle(win.hwnd)

    acId := 0
    RDA_Log_Debug(this.dllName . "\getAccessibleContextAt"
      . " Int" . element.vmId
      . this.acType . element.acId
      . " Int" . x
      . " Int" . y
      . this.acpType . acId
      . " Cdecl Int")

    acId := 0
    if !DllCall(this.dllName . "\getAccessibleContextAt"
      , "Int", element.vmId
      , this.acType, element.acId
      , "Int", x
      , "Int", y
      , this.acpType, acId
      , "Cdecl Int") {
        throw RDA_Exception("getAccessibleContextAt failed")
    }
    if (!acId) {
      throw RDA_Exception("Element not found")
    }

    return new RDA_AutomationJABElement(this, win, element.vmId, acId)
  }
  /*!
    Method: onClick
      Register a callback triggered when something is clicked.

    Remarks:
      Registering seems like a async process, wait some time to catch the events.

    Remarks:
      A single click can trigger multiple call to the callback.

    Remarks:
      see <RDA_AutomationJAB.windowFromElement> if retrieving window fail.


    Example:
    ======= AutoHotKey =======
    ; Callback definition
    jab_element_onclick(vmID, event, acId) {
      global jabInstance
      RDA_Log_Debug(A_ThisFunc . "(" . vmID . ", " . event . ", " . acId . ")")

      win := jabInstance.windowFromElement(vmID, acId)
      element := new RDA_AutomationJABElement(jabInstance, win, vmID, acId)
    }

    ; initialization
    automation := new RDA_Automation()
    automation.jab.init(JAVA_PATH)
    automation.jab.onClick("jab_element_onclick")
    ; this need to be "globaly" exposed because ahkv1 can't RegisterCallback of a FuncBound
    jabInstance := automation.jab

    ==========================

    Parameters:
      fnName - string | Func - Function name or Func

    Throws:
      Not valid function name: <fnName>
      BoundFunc is not allowed as callback
      setMouseClickedFP failed

    Returns:
      <RDA_AutomationJAB>
  */
  onClick(fnName) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . fnName . ")")

    if (!IsFunc(fnName)) {
      throw RDA_Exception("cannot find function by name: " . fnName)
    }

    ; BoundFunc not supported in v1, supported in v2
    ; FunctionObject don't work

    fp := RegisterCallback(fnName, "CDecl")
    if (!DllCall(this.dllName . "\setMouseClickedFP"
      , "UInt", fp
      , "Cdecl Int")) {
      throw RDA_Exception("setMouseClickedFP failed")
    }

    return this
  }
  /*!
    Method: onFocusIn
      Register a callback triggered when something got focus.

    Remarks:
      See <RDA_AutomationJAB.onClick>

    Example:
    ======= AutoHotKey =======
    ; Callback definition
    jab_element_focusin(vmID, event, acId) {
      global jabInstance
      RDA_Log_Debug(A_ThisFunc . "(" . vmID . ", " . event . ", " . acId . ")")

      win := jabInstance.windowFromElement(vmID, acId)
      element := new RDA_AutomationJABElement(jabInstance, win, vmID, acId)
    }
    ==========================

    Parameters:
      fnName - string | Func - Function name or Func

    Throws:
      Not valid function name: <fnName>
      BoundFunc is not allowed as callback
      SetFocusGainedFP failed

    Returns:
      <RDA_AutomationJAB>
  */
  onFocusIn(fnName) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . fnName . ")")

    if (!IsFunc(fnName)) {
      throw RDA_Exception("cannot find function by name: " . fnName)
    }

    ; BoundFunc not supported in v1, supported in v2
    ; FunctionObject don't work

    fp := RegisterCallback(fnName, "CDecl")
    if (!DllCall(this.dllName . "\SetFocusGainedFP"
      , "UInt", fp
      , "Cdecl Int")) {
      throw RDA_Exception("SetFocusGainedFP failed")
    }

    return this
  }
  /*!
    Method: onFocusOut
      Register a callback triggered when something lose focus.

    Remarks:
      See <RDA_AutomationJAB.onClick>

    Example:
    ======= AutoHotKey =======
    ; Callback definition
    jab_element_focusout(vmID, event, acId) {
      global jabInstance
      RDA_Log_Debug(A_ThisFunc . "(" . vmID . ", " . event . ", " . acId . ")")

      win := jabInstance.windowFromElement(vmID, acId)
      element := new RDA_AutomationJABElement(jabInstance, win, vmID, acId)
    }
    ==========================

    Parameters:
      fnName - string | Func - Function name or Func

    Throws:
      Not valid function name: <fnName>
      BoundFunc is not allowed as callback
      SetFocusLostFP failed

    Returns:
      <RDA_AutomationJAB>
  */
  onFocusOut(fnName) {
    local

    RDA_Log_Debug(A_ThisFunc . "(" . fnName . ")")

    if (!IsFunc(fnName)) {
      throw RDA_Exception("cannot find function by name: " . fnName)
    }

    ; BoundFunc not supported in v1, supported in v2
    ; FunctionObject don't work

    fp := RegisterCallback(fnName, "CDecl")
    if (!DllCall(this.dllName . "\SetFocusLostFP"
      , "UInt", fp
      , "Cdecl Int")) {
      throw RDA_Exception("SetFocusLostFP failed")
    }

    return this
  }
}
