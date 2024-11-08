/*!
  class: RDA_ScreenRegion
    Represents a region (x,y,w,h) in the screen
*/
class RDA_ScreenRegion extends RDA_Base {
  ;static __Call := TooFewArguments(RDA_ScreenRegion)

  origin := 0
  rect := 0

  __New(origin, rect) {
    this.origin := origin
    this.rect := rect
  }
  /*
    Static: fromPoints
      Creates a <RDA_ScreenRegion> from points

    Parameters:
      x - number - x amount
      y - number - y amount
      w - number - width (default means same as window)
      h - number - height (default means same as window)
  */
  fromPoints(automation, x, y, w, h) {
    return new RDA_ScreenRegion(new RDA_ScreenPosition(automation, x, y), new RDA_Rectangle(automation, w, h))
  }
  /*!
    Method: toString
      Dumps the object to a readable string

    Returns:
      string - debug info
  */
  toString() {
    return "RDA_ScreenRegion {x: " . this.origin.x . ", y: " . this.origin.y . ", w: " . this.rect.w . ", h: " . this.rect.h . "}"
  }
  /*!
    Method: getCenter
      Calculates the center of the region

    Returns:
      boolean - RDA_ScreenPosition
  */
  getCenter() {
    local x := this.origin.x + (this.rect.w // 2)
    local y := this.origin.y + (this.rect.h // 2)

    RDA_Log_Debug(A_ThisFunc . "(" . x . ", "  . y . ")")
    return new RDA_ScreenPosition(this.origin.automation, x, y)
  }

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
    RDA_Log_Debug(A_ThisFunc)

    ; TODO: normalize to relative ?
    return RDA_PixelSearchColor(this.origin.automation, color, this.origin.x, this.origin.y, this.rect.w, this.rect.h)
  }

  /*!
    Method: searchImage
      Searches a region of the screen for an image and returns its position

    Remarks:
      It set current window to opaque (non-transparent)

    Parameters:
      imagePath - string - Absolute image path
      sensibility - number - Color-variant sensibility. A number from 0 to 255, 0 means exact match

    Returns:
      <RDA_ScreenPosition>
  */
  searchImage(imagePath, sensibility) {
    return RDA_ImageSearch(this.origin.automation, imagePath, sensibility, this, "")
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
      <RDA_ScreenPosition>
  */
  waitAppearImage(imagePaths, sensibility, timeout := -1, delay := -1) {
    if (!RDA_IsArray(imagePaths)) {
      imagePaths := [imagePaths]
    }
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)
    return RDA_ImagesWaitAppear(this.origin.automation, imagePaths, sensibility, this, "", timeout, delay)
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
    if (!RDA_IsArray(imagePaths)) {
      imagePaths := [imagePaths]
    }
    timeout := (timeout == -1 ? RDA_Automation.TIMEOUT : timeout)
    delay := (delay == -1 ? RDA_Automation.DELAY : delay)
    return RDA_ImagesWaitDisappear(this.origin.automation, imagePaths, sensibility, this, "", timeout, delay)
  }

  /*!
    Method: screenshot
      Takes a screenshot of current region

    Parameters:
      file - string - File path
      captureCursor - boolean - Add cursor to capture ?
  */
  screenshot(file, captureCursor :=  false) {
    RDA_Log_Debug(A_ThisFunc . "(" . file . ", "  . captureCursor . ")")

    RDA_Screenshot(this.origin.x, this.origin.y, this.rect.w, this.rect.h, file, captureCursor)
  }

  /*!
    Method: highlight
      highlights current region

    Parameters:
      file - string - File path
      captureCursor - boolean - Add cursor to capture ?
  */
  highlight(displayTime:=2000, color:="Red", d:=4) {
    local
    global Log

    RDA_Log_Debug(A_ThisFunc)

    x := this.origin.x
    y := this.origin.y
    w := this.rect.w
    h := this.rect.h
    d:=Floor(d)

    Loop 4 {
      Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
      i:=A_Index
      , x1:=(i=2 ? x+w : this.origin.x-d)
      , y1:=(i=3 ? y+h : y-d)
      , w1:=(i=1 or i=3 ? w+2*d : d)
      , h1:=(i=2 or i=4 ? h+2*d : d)
      Gui, Range_%i%: Color, %color%
      Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
    }
    Sleep, %displayTime%
    Loop 4
      Gui, Range_%A_Index%: Destroy
    return this
  }

}
