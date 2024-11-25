/*!
  class: RDA_AutomationWindow
    Automation a window
*/
class RDA_AutomationWindow extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_AutomationWindow)
  /*!
    Property: automation
      <RDA_Automation> - Automation config
  */
  automation := 0
  /*!
    Property: hwnd
      number - hwnd identifier
  */
  hwnd := 0
  /*!
    Property: title
      string - Title
  */
  title := 0
  /*!
    Property: pid
      number - Process identifier
  */
  pid := 0
  /*!
    Property: process
      string - The name of the process that owns the window
  */
  process := 0
  /*!
    Property: path
      string - Full path and name of the process that owns the window
  */
  path := 0
  /*!
    Property: classNN
      string - window's class name
  */
  classNN := 0

  monitor [] {
    get {
      return this.automation.monitors().fromWindow(this.hwnd)
    }
  }

  vdesktop [] {
    get {
      return this.automation.virtualDesktops().fromWindow(this.hwnd)
    }
  }

  /*!
    Constructor: RDA_AutomationWindow

    Parameters:
      automation - <RDA_Automation>
      hwnd - hwnd identifier
  */
  __New(automation, hwnd) {
    local
    global Log

    this.automation := automation

    this.hwnd := hwnd

    RDA_Assert(this.automation, A_ThisFunc . " automation is null")
    RDA_Assert(this.hwnd, A_ThisFunc . " hwnd is null")

    WinGetTitle title, ahk_id %hwnd%
    this.title := title

    WinGet, thePID, PID, ahk_id %hwnd%
    this.pid := thePID

    WinGet, theProcess , ProcessName, ahk_id %hwnd%
    this.process := theProcess

    WinGet, theProcessPath , ProcessPath, ahk_id %hwnd%
    this.path := theProcessPath

    WinGetClass, theProcessClassNN, ahk_id %hwnd%
    this.classNN := theProcessClassNN

    ; RDA_Log_Debug(A_ThisFunc . " " . this.toString())
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string
  */
  toString() {
    return "AutomationWindow { hwnd: " . this.hwnd . ", title: " . this.title . ", pid: " . this.pid . ",process: " . this.process . ", path: " . this.path . ", classNN: " . this.classNN . "}"
  }
  /*!
    Method: getTopLevelHWND
      Retrieves the root window by walking the chain of parent windows.

    Returns:
      number
  */
  getTopLevelHWND() {
    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getancestor
    return DllCall("user32\GetAncestor", "Ptr", this.hwnd, "UInt", 2, Ptr) ;GA_ROOT := 2
  }
  /*!
    Method: isMatch
      Tests if given object match the current window.

    Example:
      ======= AutoHotKey =======
      ; title equals "Notepad"
      win.isMatch({title: "Notepad"})
      ; process equals "notepad.exe"
      win.isMatch({process: "notepad.exe"})
      ; tile regex "Accounting.*" and process equals "word.exe"
      win.isMatch({$title: "Accounting.*", process: "word.exe"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object

    Returns:
      boolean - If all properties match
  */
  isMatch(searchObject) {
    local properties := ["title", "process", "path", "classNN", "pid"]
    local allMatch := true

    loop % properties.Length() {
      p := properties[A_Index]
      if (searchObject[p]) {
        ;RDA_Log_Debug("searching: " . searchObject[p] . " on " . this[p])
        if (this[p] != searchObject[p]) {
          allMatch := false
        }
      }

      if (searchObject["$" . p]) {
        ;RDA_Log_Debug("searching: " . searchObject["$" . p] . " on " . this[p])
        if(!RegExMatch(this[p], searchObject["$" . p])) {
          allMatch := false
        }
      }
    }

    ;RDA_Log_Debug("allMatch " . allMatch)

    return allMatch
  }
  /*!
    Method: hide
      Hides the window.

    Returns:
      <RDA_AutomationWindow>
  */
  hide() {
    RDA_Window_Hide(this.hwnd)

    return this
  }
  /*!
    Method: show
      Shows the window.

    Returns:
      <RDA_AutomationWindow>
  */
  show() {
    RDA_Window_Show(this.hwnd)

    return this
  }
  /*!
    Method: close
      Closes window and wait until the specified window does not exist.

    Parameters:
      timeout - number - timeout, in miliseconds

    Returns:
      boolean - If the window exists after waiting to close
  */
  close(timeout := -1) {
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)

    return RDA_Window_Close(this.hwnd, timeout)
  }
  /*!
    Method: isClosed
      Returns if the window is closed/destroyed/killed

    Returns:
      boolean
  */
  isClosed() {
    return !RDA_Window_Exist(this.hwnd)
  }
  /*!
    Method: isActivated
      Returns if the window is the foreground

    Returns:
      boolean
  */
  isActivated() {
    return this.hwnd == DllCall("GetForegroundWindow")
  }
  /*!
    Method: isForeground
      Alias of <RDA_AutomationWindow.isActivated>

    Returns:
      boolean
  */
  isForeground() {
    return this.isActivated()
  }
  /*!
    Method: isAlive
      Returns if the window is alive

    Returns:
      boolean
  */
  isAlive() {
    return RDA_Window_Exist(this.hwnd)
  }
  /*!
    Method: move
      Changes the window position.

    Parameters:
      x - number - x screen coordinate
      y - number - y screen coordinate

    Returns:
      <RDA_AutomationWindow>
  */
  move(x, y) {
    RDA_Window_Move(this.hwnd, x, y)

    return this
  }
  /*!
    Method: resize
      Resizes the specified window.

    Parameters:
      w - Width
      h - Height

    Returns:
      <RDA_AutomationWindow>
  */
  resize(w, h) {
    RDA_Window_Resize(this.hwnd, w, h)

    return this
  }
  /*!
    Method: getPosition
      Get window screen position

    Returns:
      <RDA_ScreenPosition>
  */
  getPosition() {
    return RDA_Window_GetSizeAndPosition(this.automation, this.hwnd).origin
  }

  /*!
    Method: getSize
      Get window screen width and height

    Returns:
      <RDA_Rectangle>
  */
  getSize() {
    return RDA_Window_GetSizeAndPosition(this.automation, this.hwnd).rect
  }

  /*!
    Method: getRegion
      Retrieves a piece/entire of the current window region.

      By default get the region of the window

    Remarks:
      Region get out of sync if the windows is moved.

    Remarks:
      It can create a region outside current window bounds.

    Parameters:
      x - number - x amount
      y - number - y amount
      w - number - width (default means same as window)
      h - number - height (default means same as window)

    Returns:
      <RDA_ScreenRegion>
  */
  getRegion(x := 0, y := 0, w := 0, h := 0) {
    local region := RDA_Window_GetSizeAndPosition(this.automation, this.hwnd)
    region.origin.move(x, y)
    if (w) {
      region.rect.w := w
    }
    if (h) {
      region.rect.h := h
    }
    return region
  }

  ;
  ; window mouse
  ;

  /*!
    Method: click
      Performs a left click at given position.

      See <RDA_MouseClick>

    Parameters:
      x - number - x position (9999 will click current position)
      y - number - y position (9999 will click current position)

      <RDA_AutomationWindow>
  */
  click(x := 9999, y := 9999) {
    local pos := this.getPosition()
    if (x != 9999) {
      pos.x += x
    }
    if (y != 9999) {
      pos.y += y
    }
    this.activate()
    RDA_MouseClick(this.automation, this.hwnd, "LEFT", 1, pos.x, pos.y)

    return this
  }
  /*!
    Method: rightClick
      Performs a right click at given position.

      See <RDA_MouseClick>

    Parameters:
      x - number - x position (9999 will click current position)
      y - number - y position (9999 will click current position)

    Returns:
      <RDA_AutomationWindow>
  */
  rightClick(x := 9999, y := 9999) {
    local pos := this.getPosition()
    if (x != 9999) {
      pos.x += x
    }
    if (y != 9999) {
      pos.y += y
    }
    this.activate()
    RDA_MouseClick(this.automation, this.hwnd, "RIGHT", 1, pos.x, pos.y)

    return this
  }
  /*!
    Method: rightClick
      Performs a lft double click at given position.

      See <RDA_MouseClick>

    Parameters:
      x - number - x position (9999 will click current position)
      y - number - y position (9999 will click current position)

    Returns:
      <RDA_AutomationWindow>
  */
  doubleClick(x := 9999, y := 9999) {
    local pos := this.getPosition()
    if (x != 9999) {
      pos.x += x
    }
    if (y != 9999) {
      pos.y += y
    }
    this.activate()
    RDA_MouseClick(this.automation, this.hwnd, "LEFT", 2, pos.x, pos.y)

    return this
  }
  /*!
    Method: mouseMoveTo
      See <RDA_MouseMove>


    Returns:
      <RDA_AutomationWindow>
  */
  mouseMoveTo(x, y) {
    local pos := this.getPosition()
    RDA_MouseMove(this.automation, x + pos.x, y + pos.y)

    return this
  }

  ;
  ; window keyboard
  ;
  /*!
    Method: type
      Shortcut: <RDA_AutomationWindow.activate> + <RDA_AutomationKeyboard.type>

    Parameters:
      text - string - Text

    Returns:
      <RDA_AutomationWindow>
  */
  type(text) {
    RDA_Log_Debug(A_ThisFunc . "(text = " . text . ") " . this.automation.toString())

    this.activate()
    this.automation.keyboard().type(text, this.hwnd)

    return this
  }
  /*!
    Method: typePassword
      Shortcut: <RDA_AutomationWindow.activate> + <RDA_AutomationKeyboard.typePassword>

    Parameters:
      password - string - Text

    Returns:
      <RDA_AutomationWindow>
  */
  typePassword(password) {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ") " . this.automation.toString())

    this.activate()
    this.automation.keyboard().typePassword(password, this.hwnd)

    return this
  }
  /*!
    Method: sendKeys
      Shortcut: <RDA_AutomationWindow.activate> + <RDA_AutomationKeyboard.sendKeys>

    Parameters:
      keys - string - Keys

    Returns:
      <RDA_AutomationWindow>
  */
  sendKeys(keys) {
    RDA_Log_Debug(A_ThisFunc . "(keys = " . keys . ") " . this.automation.toString())

    this.activate()
    this.automation.keyboard().sendKeys(keys, this.hwnd)

    return this
  }
  /*!
    Method: sendPassword
      Shortcut: <RDA_AutomationWindow.activate> + <RDA_AutomationKeyboard.sendPassword>

    Parameters:
      password - password string

    Returns:
      <RDA_AutomationWindow>
  */
  sendPassword(password) {
    RDA_Log_Debug(A_ThisFunc . "(password.length = " . StrLen(password) . ") " . this.automation.toString())

    this.activate()
    this.automation.keyboard().sendPassword(password, this.hwnd)


    return this
  }

  ;
  ; query child windows
  ;

  /*!
    Method: getChildren
      Get all children windows that match given searchObject

    Example:
      ======= AutoHotKey =======
      ; get all popup
      popups := win.getChildren({classNN: "#32770"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Returns:
      <RDA_AutomationWindow>[]
  */
  getChildren(searchObject := 0, hidden := false) {
    local wins := this.automation.windows().find({"pid" : this.pid}, hidden)
    local rwins := []
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ")")

    loop % wins.length() {
      win := wins[A_Index]
      if (!searchObject || win.isMatch(searchObject)) {
        rwins.push(win)
      }
    }

    RDA_Log_Debug(A_ThisFunc . " Found " . rwins.length() . " windows")

    return rwins
  }
  /*!
    Method: getChild
      Get the child window that match given searchObject

    Example:
      ======= AutoHotKey =======
      ; get popup
      popup := win.getChild({classNN: "#32770"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Throws:
      Window not found
      Multiple windows found

    Returns:
      <RDA_AutomationWindow>[]
  */
  getChild(searchObject, hidden := false) {
    local rwins
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . ")")

    rwins := this.getChildren(searchObject, hidden)
    if (!rwins.length()) {
      throw RDA_Exception("Window not found")
    }
    if (rwins.length() > 1) {
      throw RDA_Exception("Multiple windows found")
    }

    return rwins[1]
  }
/*!
    Method: waitChild
      Waits the child window that match given searchObject (only one)

    Example:
      ======= AutoHotKey =======
      ; get all popup
      popup := win.waitChild({classNN: "#32770"})
      ==========================

    Parameters:
      searchObject - <RDA_AutomationWindowSearch> - search object
      hidden - boolean - Search hidden windows?

    Returns:
      <RDA_AutomationWindow>[]
  */
  waitChild(searchObject, hidden := false, timeout := -1, delay := -1) {
    local bound
    timeout := timeout == -1 ? RDA_Automation.TIMEOUT : timeout
    delay := delay == -1 ? RDA_Automation.DELAY : delay
    RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(searchObject) . ", hidden? " . (hidden ? "yes" : "no") . " timeout = " . timeout . ", delay = " . delay . ")")

    bound := ObjBindMethod(this, "getChild", searchObject, hidden)
    return RDA_RepeatWhileThrows(bound, timeout, delay)
  }

  ;
  ; window management
  ;

  /*!
    Method: activate
      Activates / Bring to front / foreground window

    Remarks:
      It switch to virtual desktop if needed.

    Returns:
      <RDA_AutomationWindow>
  */
  activate() {
    RDA_Window_Activate(this.hwnd, RDA_Automation.TIMEOUT, RDA_Automation.DELAY)

    return this
  }

  /*!
    Method: isMinimized
      Returns if the window is minimized

    Returns
      boolean - Is minimized
  */
  isMinimized() {
    return RDA_Window_IsMinimized(this.hwnd)
  }
  /*!
    Method: winIsMaximized
      Returns if the window is maximized
  */
  isMaximized() {
    return RDA_Window_IsMaximized(this.hwnd)
  }
  /*!
    Method: winIsRestored
      Returns if the window is neither minimized nor maximized
  */
  isRestored() {
    return RDA_Window_IsRestored(this.hwnd)
  }
  /*!
    Method: maximize
      Enlarges the specified window to its maximum size.

      https://www.autohotkey.com/docs/commands/WinMaximize.htm

    Parameters:
      hwnd - number - window identifier
  */
  maximize() {
    RDA_Log_Debug(A_ThisFunc . "()")

    ; be gentle as always
    if (this.isMaximized()) {
      return
    }

    RDA_Window_Maximize(this.hwnd)

    return this
  }

  /*!
    Method: winRestore
      Restores the specified window

    Returns:
      <RDA_AutomationWindow>
  */
  restore() {
    RDA_Log_Debug(A_ThisFunc . "()")

    ; The window is neither minimized nor maximized.
    if (this.isRestored()) {
      return
    }
    RDA_Window_Restore(this.hwnd)

    return this
  }
  /*!
    Method: winMinimize
      Minimizes the current window

    Returns:
      <RDA_AutomationWindow>
  */
  minimize() {
    RDA_Log_Debug(A_ThisFunc . "()")

    ; be gentle as always
    if (this.isMinimized()) {
      return
    }

    RDA_Window_Minimize(this.hwnd)

    return this
  }
  /*!
    Method: pixel
      Points to given pixel of the window.

    Parameters:
      x - number
      y - number

    Returns:
      <RDA_ScreenPosition> - screen position
  */
  pixel(x, y) {
    local pos := this.getPosition()
    pos.move(x, y)
    return pos
  }

  /*!
    Method: getColor
      Retrieves the color of the pixel at the specified screen position. (<RDA_PixelGetColor>)

    Remarks:
      0xFFFFFFFF is the actual value returned when Workstation is locked

    Returns:
      number - RGB color
  */
  getColor(x, y) {
    local pos := this.getPosition()
    this.activate()
    return RDA_PixelGetColor(pos.x + x, pos.y + y)
  }
  /*!
    Method: searchColor
      Searches a region of the screen for a pixel of the specified color.

    Parameters:
      color - number - RGB color
      variation - number - Number of shades of variation. See: https://www.autohotkey.com/docs/v1/lib/PixelSearch.htm#Parameters

    Throws:
      Color not found

    Returns:
      <RDA_ScreenPosition>
  */
  searchColor(color, variation := "") {
    local region := this.getRegion()
    this.activate()

    ; TODO: normalize to relative ?
    return RDA_PixelSearchColor(this.automation, color, region.origin.x, region.origin.y, region.rect.w, region.rect.h)
  }

  ;
  ; image
  ;

  /*!
    Method: searchImage
      Searches a region of the screen for an image and returns its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePath - string - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match

    Returns:
      <RDA_ScreenRegion>
  */
  searchImage(imagePath, sensibility) {
    this.setOpaque()
    return this.getRegion().searchImage(imagePath, sensibility)
  }
  /*!
    Method: waitAppearImage
      Searches a region of the screen for first image until it appears and return its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePaths - string|string[] - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match

    Returns:
      <RDA_ScreenRegion>
  */
  waitAppearImage(imagePaths, sensibility, timeout := -1, delay := -1) {
    this.setOpaque()
    return this.getRegion().waitAppearImage(imagePaths, sensibility, timeout, delay)
  }
  /*!
    Method: waitDisappearImage
      Searches a region of the screen for first image until it appears and return its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePaths - string|string[] - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match

    Returns:
      number - Index of the image not found (1 if a string was sent)
  */
  waitDisappearImage(imagePaths, sensibility, timeout := -1, delay := -1) {
    this.setOpaque()
    return this.getRegion().waitDisappearImage(imagePaths, sensibility, timeout, delay)
  }

  /*!
    Method: setOpaque
      Disable windows transparency

    Returns:
      <RDA_AutomationWindow>
  */
  setOpaque() {
    RDA_Window_Opaque(this.hwnd)

    return this
  }
  /*!
    Method: setTransparent
      Enables windows transparency

    Returns:
      <RDA_AutomationWindow>
  */
  setTransparent() {
    RDA_Window_Transparent(this.hwnd)

    return this
  }

  /*!
    Method: screenshot
      Takes a screenshot of current region

    Parameters:
      file - string - File path
      captureCursor - boolean - Add cursor to capture ?

    Returns:
      <RDA_AutomationWindow>
  */
  screenshot(file, captureCursor :=  false) {
    this.getRegion().screenshot(file, captureCursor)

    return this
  }
  /*!
    Method: waitClose
      Waits window to be closed

    Parameters:
      timeout - number - Timeout, in miliseconds

    Returns:
      <RDA_AutomationWindow>
  */
  waitClose(timeout := -1) {
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    RDA_Window_WaitClose(this.hwnd, timeout)

    return this
  }
  /*!
    Method: copyToClipboard
      Alias of <RDA_AutomationClipboard.copy> but activate current window before.

    Parameters:
      keys - string - Copy command by default CTRL+C
      timeout - number - timeout, in miliseconds
      delay - number - retry delay, in miliseconds

    Returns:
      string - Clipboard contents
  */
  copyToClipboard(keys := "{Ctrl down}c{Ctrl up}", timeout := -1, delay := -1) {
    this.activate()
    return this.automation.clipboard().copy()
  }
  ;
  ; UIAutomation
  ;
  /*!
    Method: asUIAElement
      Retrieves current windows as RDA_AutomationUIAElement

    Example:
      ======= AutoHotKey =======
      automation := new RDA_Automation()
      windows := automation.windows()
      win := windows.waitOne({process: "notepad.exe"})
      element := win.asUIAElement()
      ==========================

    Throws:
      Not found

    Returns:
      <RDA_AutomationUIAElement>
  */
  asUIAElement() {
    RDA_Log_Debug(A_ThisFunc)

    return new RDA_AutomationUIAElement(this.automation, this, this.automation.UIA.elementFromHandle(this.hwnd))
  }
  /*!
    Method: asJABElement
      Retrieves current windows as RDA_AutomationJABElement

    Example:
      ======= AutoHotKey =======
      automation := new RDA_Automation()
      windows := automation.windows()
      win := windows.waitOne({process: "java.exe"})
      element := win.asJABElement()
      ==========================

    Throws:
      Not found

    Returns:
      <RDA_AutomationJABElement>
  */
  asJABElement() {
    RDA_Log_Debug(A_ThisFunc)

    return this.automation.jab.elementFromHandle(this.hwnd)
  }
}
