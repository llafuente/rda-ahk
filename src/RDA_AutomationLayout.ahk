/*!
  Class: RDA_LayoutElement
    Base class for RAW Automation element
*/
class RDA_LayoutElement {
  /*!
    property: layout
      <RDA_Layout> - layout
  */
  layout := 0
  /*!
    property: name
      string - name
  */
  name := ""
  /*!
    property: name
      string - name
  */
  type := ""
  /*!
    property: region
      <RDA_WindowRegion> - region
  */
  region := 0
  ; internal
  _parseCommonProperties(obj) {
    local
    global RDA_Layout, RDA_WindowRegion

    if (!RDA_Array_IndexOf(RDA_Layout.types, obj.type)) {
      throw RDA_Exception("Invalid type: " . obj.type)
    }

    this.name := obj.name
    this.type := obj.type
    this.region := RDA_WindowRegion.fromPoints(this.layout.win, obj.region.x, obj.region.y, obj.region.w, obj.region.h)

    RDA_Assert(this.name, "invalid property name is required")
    RDA_Assert(this.type, "invalid property type is required")
    RDA_Assert(this.region, "invalid property region is required")
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_LayoutElement{name: " . this.name . ", type: " . this.type . ", region: " . this.region.toString() . "}"
  }
  /*!
    Method: getCenter
      Calculates the center of the element

    Returns:
      <RDA_ScreenPosition>
  */
  getCenter() {
    return this.region.getCenter().add(this.layout.offset) ;.add(this.layout.win.getPosition())
  }
  /*!
    Method: highlight
      Highlights current region

    Returns:
      <RDA_LayoutElement>
  */
  highlight() {
    local

    r := this.region.clone()
    r.origin.add(this.layout.offset).add(this.layout.win.getPosition())
    r.highlight()

    return this
  }
  /*!
    Method: hover
      Hover the element

    Returns:
      <RDA_LayoutElement>
  */
  hover() {
    local

    pos := this.getCenter()
    this.layout.win.mouseMoveTo(pos.x, pos.y)

    return this
  }
  /*!
    Method: click
      Performs a left click at the region center.

    Returns:
      <RDA_LayoutElement>
  */
  click() {
    local

    pos := this.getCenter()
    this.layout.win.click(pos.x, pos.y)

    return this
  }
  /*!
    Method: rightClick
      Performs a right click at the region center.

      See <RDA_Mouse_WindowClick>

    Returns:
      <RDA_LayoutElement>
  */
  rightClick() {
    local

    pos := this.getCenter()
    this.layout.win.rightClick(pos.x, pos.y)

    return this
  }
  /*!
    Method: rightClick
      Performs a lft double click at the region center

      See <RDA_Mouse_WindowClick>

    Returns:
      <RDA_LayoutElement>
  */
  doubleClick() {
    local

    pos := this.getCenter()
    this.layout.win.doubleClick(pos.x, pos.y)

    return this
  }
    /*!
    Method: hover
      Sleeps

    Parameters:
      ms - number - Timeout, in miliseconds

    Returns:
      <RDA_LayoutElement>
  */
  sleep(ms) {
    local

    sleep % ms

    return this
  }
}

/*!
  Class: RDA_LayoutImage
    Static header

  Extends: RDA_LayoutElement
*/
class RDA_LayoutImage extends RDA_LayoutElement {
  /*!
    Property: image
      string - Path to image
  */
  image := ""
  /*!
    Constructor: RDA_LayoutImage

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)

    ; optional
    if (obj.HasKey("image")) {
      this.image := A_WorkingDir . "\" . obj.image
    }
    RDA_Assert(this.image, "invalid property image is required")
  }
  /*!
    Method: updateImage
      Takes a screenshot of current element region and save to image

    Returns:
      <RDA_LayoutEdit>
  */
  updateImage() {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . this.image . ")")

    if (!StrLen(this.image)) {
      throw RDA_Exception("image not defined")
    }

    return this._updateImage(this.image)
  }
  ; internal
  _updateImage(filepath) {
    this.layout.win.setOpaque()
    r := this.region.clone()
    r.origin.add(this.layout.offset).add(this.layout.win.getPosition())
    r.screenshot(filepath)

    return this
  }
  /*!
    Method: waitAppear
      Searches a region of the screen for image until it appears

    Parameters:
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_LayoutImage>
  */
  waitAppear(sensibility := -1, timeout := -1, delay := -1) {
    local
    RDA_Log_Debug(A_ThisFunc)

    ; TODO smaller region ?
    pos := this.layout.win.waitAppearImage([this.image], sensibility, timeout, delay)
    ; TODO check position is inside the region ?
    return this
  }
  /*!
    Method: waitDisappear
      Searches a region of the screen for image until it disappear

    Parameters:
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_LayoutImage>
  */
  waitDisappear(sensibility := -1, timeout := -1, delay := -1) {
    local
    RDA_Log_Debug(A_ThisFunc)

    ; TODO smaller region ?
    this.layout.win.waitDisappearImage(this, [this.image], sensibility, timeout, delay)
    ; TODO check position is inside the region ?
    return this
  }
}

/*!
  Class: RDA_LayoutEdit
    Automate: Edit, Input, Textarea. A box that you type and value is set

  Extends: RDA_LayoutElement
*/
class RDA_LayoutEdit extends RDA_LayoutElement {
  /*!
    Property: clearKeys
      Keys that need to be pressed to clear input value

      * {HOME}{LShift Down}{RIGHT}{LShift Up}{BackSpace}

      * {HOME}{Delete 100}
  */
  clearKeys := "{LCtrl Down}{a}{LCtrl Up}{BackSpace}"
  /*!
    Property: enterKeys
      Keys that need to be pressed to set the value
  */
  exitKeys := ""
  /*!
    Constructor: RDA_LayoutEdit

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)

    if (obj.HasKey("clearKeys")) {
      this.clearKeys := obj.clearKeys
    }
    if (obj.HasKey("exitKeys")) {
      this.exitKeys := obj.exitKeys
    }

  }
  /*!
    Method: setValue
      Sets item value

    Remarks:
      Sending an empty string will clear the value with "{LCtrl Down}{a}{LCtrl Up}{BackSpace}"

    Parameters:
      value - string

    Returns:
      <RDA_LayoutEdit>
  */
  setValue(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")
    return this._setValue(value)
  }
  /*!
    Method: setPassword
      Sets item password (hide value to log)

    Parameters:
      value - string

    Returns:
      <RDA_LayoutEdit>
  */
  setPassword(value) {
    RDA_Log_Debug(A_ThisFunc . "(length = " . StrLen(value) . ")")
    return this._setValue(value)
  }
  ; internal
  _setValue(value) {
    this.click()
    if (StrLen(value)) {
      this.layout.win.typePassword(value)
      if (StrLen(this.exitKeys)) {
        this.layout.win.sendKeys(this.exitKeys)
      }
    } else {
      if (StrLen(this.clearKeys)) {
        this.layout.win.sendKeys(this.clearKeys)
      } else {
        RDA_Log_Debug(A_ThisFunc . " request to clear value but there is no clearKeys defined")
      }
    }

    return this
  }
}
/*!
  Class: RDA_LayoutStaticDropdown
    A dropdown with all known values and in the same order.

  Extends: RDA_LayoutElement
*/
class RDA_LayoutStaticDropdown extends RDA_LayoutElement {
  /*!
    Constructor: RDA_LayoutStaticDropdown

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)

    this.options := obj.options
    RDA_Assert(this.options, "invalid property options is required")
    RDA_Assert(this.options.length(), "invalid property options at least one value is required")
  }
  /*!
    Method: selectByValue
      Search the value and call <RDA_LayoutStaticDropdown.select>

    parameters:
      value - string - value

    Throws:
      Invalid type, select is only avaiable for Dropdown: ?

    Returns:
      <RDA_LayoutStaticDropdown>
  */
  selectByValue(value) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")

    index := RDA_Array_IndexOf(this.options, value)

    if (!index) {
      throw RDA_Exception("Value not found")
    }

    return this.select(index)
  }
  /*!
    Method: select
      Opens a drowdown and select by pressing down index times.

    parameters:
      index - number - 1index

    Throws:
      Invalid type, select is only avaiable for Dropdown: ?

    Returns:
      <RDA_LayoutStaticDropdown>
  */
  select(index) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . index . ")")

    this.click()
    this.layout.win.sendKeys("{HOME}{DOWN " . (index - 1) . "}{ENTER}")

    return this
  }
}

/*!
  Class: RDA_LayoutAutocompleteDropdown

  Extends: RDA_LayoutElement
*/
class RDA_LayoutAutocompleteDropdown extends RDA_LayoutElement {
  /*!
    Property: enterKeys
      Keys that need to be pressed before set a value
  */
  enterKeys := ""
  /*!
    Property: enterKeys
      Keys that need to be pressed to set the value
  */
  exitKeys := ""
  /*!
    Constructor: RDA_LayoutAutocompleteDropdown

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)

    if (obj.HasKey("enterKeys")) {
      this.enterKeys := obj.enterKeys
    }
    if (obj.HasKey("exitKeys")) {
      this.exitKeys := obj.exitKeys
    }
  }
  /*!
    Method: selectByValue
      Clicks and the fill given value follower by {ENTER}

    parameters:
      value - string - value

    Throws:
      Invalid type, select is only avaiable for Dropdown: ?

    Returns:
      <RDA_LayoutAutocompleteDropdown>
  */
  selectByValue(value) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . value . ") enterKeys = """ . this.enterKeys . """  exitKeys = """ . this.exitKeys . """")

    this.click()
    if (StrLen(this.enterKeys)) {
      this.layout.win.sendKeys(this.enterKeys)
    }
    this.layout.win.typePassword(value)
    if (StrLen(this.exitKeys)) {
      this.layout.win.sendKeys(this.exitKeys)
    }

    return this
  }
}


/*!
  Class: RDA_LayoutCheckbox
    Checkbox

  Extends: RDA_LayoutElement
*/
class RDA_LayoutCheckbox extends RDA_LayoutElement {
  /*!
    Constructor: RDA_LayoutCheckbox

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)
  }
  /*!
    Method: toggle
      Alias of <RDA_LayoutElement.click>

    Returns:
      <RDA_LayoutAutocompleteDropdown>
  */
  toggle() {
    local
    RDA_Log_Debug(A_ThisFunc)

    this.click()

    return this
  }
}
/*!
  Class: RDA_LayoutButton
    A button is something that just recieve clicks, can be enabled/disabled.

  Extends: RDA_LayoutImage

  Remarks:
    image is the enabled button

    disabledImage is the disabled button

    At least one shall be define to use isDisabled
*/
class RDA_LayoutButton extends RDA_LayoutImage {
  /*!
    Property: disabledImage
      string - Path to disabledImage
  */
  disabledImage := ""
  /*!
    Constructor: RDA_LayoutButton

    Parameters:
      layout - <RDA_Layout> - layout
      obj - object - plain object
  */
  __New(layout, obj) {
    this.layout := layout

    RDA_Assert(layout, "invalid parameters layout is required")
    RDA_Assert(RDA_instaceOf(layout, RDA_Layout), "expected layout to be instance of RDA_Layout")

    this._parseCommonProperties(obj)

    if (obj.HasKey("image")) {
      this.image := A_WorkingDir . "\" . obj.image
    }
    if (obj.HasKey("disabledImage")) {
      this.disabledImage := A_WorkingDir . "\" . obj.disabledImage
    }
    ; it's optional
  }
  /*!
    Method: updateImage
      Takes a screenshot of current element region and save to image

    Returns:
      <RDA_LayoutEdit>
  */
  updateDisabledImage() {
    local
    RDA_Log_Debug(A_ThisFunc)

    if (!StrLen(this.disabledImage)) {
      throw RDA_Exception("disabledImage not defined")
    }

    return this._updateImage(this.disabledImage)
  }
  /*!
    method: isDisabled
      Searches <RDA_LayoutButton.image> if found returns false

    Parameters:
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match

    Throws:
      image is required

    Returns:
      boolean
  */
  isDisabled(sensibility := -1) {
    local

    if (this.image) {
      try {
      ; TODO search only in given region ?
        this.layout.win.searchImage([this.image], sensibility)
        return false
      } catch e {
        return true
      }
    }

    if (this.disabledImage) {
      try {
      ; TODO search only in given region ?
        this.layout.win.searchImage([this.disabledImage], sensibility)
        return true
      } catch e {
        return false
      }
    }
    throw RDA_Exception("image or disabledImage is required")

  }
  /*!
    method: waitEnabled
      Waits button to be enabled

    Parameters:
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Throws:
      image is required

    Returns:
      boolean
  */
  waitEnabled(sensibility := -1, timeout := -1, delay := -1) {
    local

    RDA_Assert(this.image, "image is required")

    return this.waitAppear(sensibility, timeout, delay)
  }
  /*!
    method: waitDisabled
      Waits button to be disabled

    Parameters:
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Throws:
      image is required

    Returns:
      boolean
  */
  waitDisabled(sensibility := -1, timeout := -1, delay := -1) {
    local

    RDA_Assert(this.disabledImage, "disabledImage is required")

    pos := this.layout.win.waitAppearImage([this.disabledImage], sensibility, timeout, delay)

    return this
  }
}

/*!
  class: RDA_Layout
    Automate RAW applications via Image/Keyboard/Mouse in a way it does not require
    to change code to move things around.

    Creates an abstraction layer from AHK-code to the application by defining
    named regions for each applications element.

    <RDA_Layout> it's a factory of elements so you can add your own custom
    implementations.

  Example:
    ======= AutoHotKey =======
    automation := new RDA_Automation()
    windows := automation.windows()
    win := windows.waitOne({process: "mspaint.exe"})

    class MyInputClass extends RDA_LayoutElement {
      __New(layout, obj) {
        this.layout := layout
        RDA_Assert(this.layout, "invalid parameters layout is required")
        this._parseCommonProperties(obj)

        ; handle here your custom properties
      }
      ; your custom methods :D
      doYourMagic() {
      }
    }

    ; add new elements to the factory
    RDA_Layout.types.push("MyInput")
    RDA_Layout.classes.push(MyInputClass)

    layout := new RDA_Layout(win)
    layout.fromJsonFile(A_WorkingDir . "\app-form-01.json")
    layout.waitAppear()
    layout.element("username").setValue("user")
    layout.element("password").setPassword("nomoresecrets")
    layout.element("login").click()
    ; layout.element("custom").doYourMagic()
    layout.waitDisappear()

    ==========================
*/
class RDA_Layout extends RDA_Base {
  /*!
    constant: types
      string[] - List of valid values for type
  */
  static types := ["Image","Input", "Dropdown", "AutoDropdown", "Checkbox", "Button"]
  /*!
    constant: classes
      string[] - List of factory classes
  */
  static classes := [RDA_LayoutImage, RDA_LayoutEdit, RDA_LayoutStaticDropdown, RDA_LayoutAutocompleteDropdown, RDA_LayoutCheckbox, RDA_LayoutButton]
  /*!
    property: win
      <RDA_AutomationWindow> - window
  */
  win := []
  /*!
    property: offset
      <RDA_ScreenPosition> - win-layout offset
  */
  offset := 0
  /*!
    property: elements
      <RDA_LayoutElement>[] - elements
  */
  elements := []
  /*!
    Constructor: RDA_LayoutButton

    Parameters:
      win - <RDA_AutomationWindow> - window
  */
  __New(win) {
    local
    global RDA_AutomationWindow

    this.automation := win.automation
    this.win := win

    RDA_Assert(this.win, "invalid parameter win is required")
    RDA_Assert(this.automation, "invalid parameter automation is required")

    RDA_Assert(RDA_instaceOf(win, RDA_AutomationWindow), "expected win to be instance of RDA_AutomationWindow")
  }
  /*!
    Method: fromJsonFile
      Reads and parse given json file

    Parameters:
      filepath - string - full file path

    Returns:
      <RDA_Layout>
  */
  fromJsonFile(filepath) {
    local
    global RDA_LayoutElement, RDA_Layout, RDA_ScreenPosition


    RDA_Log_Debug(A_ThisFunc . "(" . filepath . ")")

    f := FileOpen(filepath, "r", "UTF-8")

    if (!f) {
      throw RDA_Exception("FileOpen failed with error: " . A_LastError)
    }

    str := f.Read()
    f.close()
    RDA_Log_Debug(A_ThisFunc . "(" . filepath . ") " . StrLen(str) . " bytes")
    obj := RDA_JSON_parse(str)

    return this.from(obj)
  }
  /*!
    Method: from
      Fill layout with given obj

    Parameters:
      obj - object - object

    Returns:
      <RDA_Layout>
  */
  from(obj) {
    local
    global RDA_LayoutElement, RDA_Layout, RDA_ScreenPosition

    RDA_Log_Debug(A_ThisFunc . "()")

    this.offset := new RDA_ScreenPosition(this.automation, obj.offset.x, obj.offset.y)
    loop % obj.elements.length() {
      o := obj.elements[A_Index]

      if (!o.type) {
        throw RDA_Exception("type is required at item at position: " . A_Index )
      }

      idx := RDA_Array_IndexOf(RDA_Layout.types, o.type)
      if (!idx) {
        throw RDA_Exception("Invalid type: " . o.type . " not declared in the factory.")
      }

      cls := RDA_Layout.classes[idx]
      item := new cls(this, o)
      RDA_Log_Debug(A_ThisFunc . " add item = " . item.toString())
      this.elements.push(item)
    }
    RDA_Log_Debug(A_ThisFunc . "() read " . this.elements.length() . " elements")

    return this
  }
  /*!
    Method: waitAppear
      Waits all headers images to appear

    Parameters:
      type - string - Layout element type of wait
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_Layout>
  */
  waitAppear(type := "Image", sensibility := -1, timeout := -1, delay := -1) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . type . ")")

    loop % this.elements.length() {
      element := this.elements[A_Index]
      if (element.type == "Image") {

        RDA_Assert(element.image, "element found with type [" . type . "] but no image defined")
        RDA_Assert(FileExist(element.image), "image not found [" . element.image . "]: " . element.name)

        this.win.waitAppearImage([element.image], sensibility, timeout, delay)
      }
    }

    return this
  }
  /*!
    Method: waitDisappear
      Waits all headers images to disappear

    Parameters:
      type - string - Layout element type of wait
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_Layout>
  */
  waitDisappear(type := "Image", sensibility := -1, timeout := -1, delay := -1) {
    local
    RDA_Log_Debug(A_ThisFunc)

    loop % this.elements.length() {
      element := this.elements[A_Index]
      if (element.type == type) {

        RDA_Assert(element.image, "element found with type[" . type . "] but no image defined")
        RDA_Assert(FileExist(element.image), "image not found: " . element.name)

        this.win.waitDisappearImage([element.image], sensibility, timeout, delay)
      }
    }

    return this
  }
  /*!
    Method: element
      Searches an element by name and returns it

    Parameters:
      name - string

    Throws:
      element not found with name: ?

    Returns:
      <RDA_LayoutElement>
  */
  element(name) {
    loop % this.elements.length() {
      element := this.elements[A_Index]
      if (element.name == name) {
        return element
      }
    }

    throw RDA_Exception("element not found with name: " . name)
  }
}
