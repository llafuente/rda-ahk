class RDA_Region extends RDA_Base {
  /*!
    Property: automation
      <RDA_Automation> - automation config
  */
  automation[] {
    get {
      return this.origin.automation
    }
  }
  /*!
    Property: origin
      <RDA_ScreenPosition> - origin of the region
  */
  origin := 0
  /*!
    Property: rect
      <RDA_Rectangle> - size of the region
  */
  rect := 0
  /*!
    Property: x
      number - Getter shortcut to origin.x
  */
  x[] {
    get {
      return this.origin.x
    }
  }
  /*!
    Property: y
      number - Getter shortcut to origin.y
  */
  y[] {
    get {
      return this.origin.y
    }
  }
  /*!
    Property: w
      number - Getter shortcut to rect.w
  */
  w[] {
    get {
      return this.rect.w
    }
  }
  /*!
    Property: h
      number - Getter shortcut to rect.w
  */
  h[] {
    get {
      return this.rect.h
    }
  }

  ;
  ; mouse
  ;

  /*!
    Method: click
      Clicks at region center, Alias of <RDA_AutomationMouse.click>
  */
  click() {
    this.getCenter().click()
  }
  /*!
    Method: rightClick
      Right clicks at region center, Alias of <RDA_AutomationMouse.rightClick>
  */
  rightClick() {
    this.getCenter().rightClick()
  }
  /*!
    Method: doubleClick
      Double clicks at region center, Alias of <RDA_AutomationMouse.doubleClick>
  */
  doubleClick() {
    this.getCenter().doubleClick()
  }

  ;
  ; math
  ;

  /*!
    Method: expandLeft
      Expands region to the left

    Parameters:
      value - number - value

    Returns:
      <RDA_ScreenRegion>
  */
  expandLeft(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")
    this.origin.x -= value
    return this
  }
  /*!
    Method: expandUp
      Expands region upwards

    Parameters:
      value - number - value

    Returns:
      <RDA_ScreenRegion>
  */
  expandUp(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")
    this.origin.y -= value
    return this
  }
  /*!
    Method: expandRight
      Expands region to the right

    Parameters:
      value - number - value

    Returns:
      <RDA_ScreenRegion>
  */
  expandRight(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")
    this.rect.w += value
    return this
  }
  /*!
    Method: expandRight
      Expands region downwards

    Parameters:
      value - number - value

    Returns:
      <RDA_ScreenRegion>
  */
  expandDown(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")
    this.rect.h += value
    return this
  }
  /*!
    Method: expandOut
      Expands region outwards

    Parameters:
      value - number - value

    Returns:
      <RDA_ScreenRegion>
  */
  expandOut(value) {
    RDA_Log_Debug(A_ThisFunc . "(" . value . ")")

    this.origin.x -= value
    this.origin.y -= value
    this.rect.w += value * 2
    this.rect.h += value * 2

    return this
  }

  ;
  ; colors
  ;
  /*!
    Method: searchColor

    Parameters:
      color - number - RGB color
      variation - number - Number of shades of variation. See: https://www.autohotkey.com/docs/v1/lib/PixelSearch.htm#Parameters

    Throws:
      Color not found

    Returns:
      <RDA_ScreenPosition>
  */
  searchColor(color, variation := "") {
    local

    RDA_Log_Debug(A_ThisFunc)

    region := this.toScreen()
    return RDA_PixelSearchColor(this.origin.automation, color, region.x, region.y, region.w, region.h)
  }

  ;
  ; screenshots
  ;
  /*!
    Method: screenshot
      Takes a screenshot of current region

    Parameters:
      file - string - File path
      captureCursor - boolean - Add cursor to capture ?
  */
  screenshot(file, captureCursor :=  false) {
    local
    RDA_Log_Debug(A_ThisFunc . "(" . file . ", "  . captureCursor . ")")

    region := this.toScreen()
    RDA_Screenshot(region.x, region.y, region.w, region.h, file, captureCursor)
  }

  ;
  ; images
  ;
  /*!
    Method: searchImage
      Searches a region of the screen for an image and returns its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePath - string - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_ScreenPosition>
  */
  searchImage(imagePath, sensibility := -1) {
    local

    region := this.toScreen()
    return RDA_ImageSearch(this.origin.automation, imagePath, sensibility, region, "")
  }
  /*!
    Method: waitAppearImage
      Searches a region of the screen for first image until it appears and return its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePaths - string|string[] - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match
      timeout - number - Timeouts, in miliseconds
      delay - number - Retries delay, in miliseconds

    Returns:
      <RDA_ScreenPosition>
  */
  waitAppearImage(imagePaths, sensibility := -1, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    region := this.toScreen()
    if (!RDA_IsArray(imagePaths)) {
      imagePaths := [imagePaths]
    }
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)
    return RDA_ImagesWaitAppear(this.origin.automation, imagePaths, sensibility, region, "", timeout, delay)
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
  waitDisappearImage(imagePaths, sensibility := -1, timeout := -1, delay := -1) {
    local
    global RDA_Automation

    region := this.toScreen()
    if (!RDA_IsArray(imagePaths)) {
      imagePaths := [imagePaths]
    }
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)
    return RDA_ImagesWaitDisappear(this.origin.automation, imagePaths, sensibility, region, "", timeout, delay)
  }

  ;
  ; overlay draw
  ; use toScreen, to not repeat code screenRegion will just "return this"
  ;

  /*!
    Method: drawFill
      Draws a colored rectangle

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_WindowRegion> - for chaining
  */
  drawFill(overlay, color) {
    RDA_Log_Debug(A_ThisFunc)

    overlay.fillRectangle(this.toScreen(), color)

    return this
  }
  /*!
    Method: borderRectangle
      Draws a rectangle border

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawBorder(overlay, color, size := 1) {
    RDA_Log_Debug(A_ThisFunc)

    overlay.borderRectangle(this.toScreen(), color, size)

    return this
  }
  /*!
    Method: drawFillEllipse
      Draws a filled ellipse

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawFillEllipse(overlay, color) {
    RDA_Log_Debug(A_ThisFunc)

    overlay.fillEllipse(this.toScreen(), color)

    return this
  }

  /*!
    Method: drawFillEllipse
      Draws a border ellipse

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawBorderEllipse(overlay, color, size := 1) {
    RDA_Log_Debug(A_ThisFunc)

    overlay.borderEllipse(this.toScreen(), color, size)

    return this
  }

  /*!
    Method: drawImage
      Draws an image into given region

    Parameters:
      overlay - <RDA_Overlay> - overlay win
      imagePath - string - image path

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawImage(overlay, imagePath) {
    RDA_Log_Debug(A_ThisFunc)

    overlay.drawImage(imagePath, this.toScreen())

    return this
  }
}
