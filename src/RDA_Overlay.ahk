/*!
  Class: RDA_Overlay
    Creates a window overlay at a given region.

  Remarks:
    Do not interfere with inputs / mouse.
*/
class RDA_Overlay {
  automation := 0
  pToken := 0
  hwnd := 0
  hbm := 0
  hdc := 0
  obm := 0
  G := 0

  objects := []

  /*!
    Constructor: RDA_Overlay

    Parameters:
      automation - <RDA_Automation> -
      region - <RDA_ScreenRegion> - default is the primary screen
  */
  __New(automation, region := 0) {
    local
    global RDA_ScreenRegion

    RDA_Assert(automation, A_ThisFunc . " automation is null")
    this.automation := automation

    if (!region) {
      region := RDA_ScreenRegion.fromPrimaryScreen(automation)
    }

    RDA_Log_Debug(A_ThisFunc . "(" . region.toString() . ")")

    ; Start gdi+
    If (!this.pToken := Gdip_Startup()) {
      throw RDA_Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system")
    }

    ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
    ; Ignore mouse +E0x20
    Gui, Overlay: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20 +hwndhwnd
    opt := "NA X0 Y0 W" . A_ScreenWidth . " H" . A_ScreenHeight
    Gui, Overlay: Show, % opt


    ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
    this.hbm := CreateDIBSection(region.w, region.h)
    RDA_Assert(this.hbm != 0, "CreateDIBSection failed")

    ; Get a device context compatible with the screen
    this.hdc := CreateCompatibleDC()
    RDA_Assert(this.hdc != 0, "CreateCompatibleDC failed")

    ; Select the bitmap into the device context
    this.obm := SelectObject(this.hdc, this.hbm)
    RDA_Assert(this.obm != 0, "SelectObject failed")

    ; Get a pointer to the graphics of the bitmap, for use with drawing functions
    this.G := Gdip_GraphicsFromHDC(this.hdc)
    RDA_Assert(this.G != 0, "Gdip_GraphicsFromHDC failed")

    Gdip_SetSmoothingMode(this.G, 4)

    this.hwnd := hwnd
    RDA_Log_Debug(A_ThisFunc . " " . this.toString())
  }
  ; internal, destructor
  __Delete() {
    local

    ; Select the object back into the hdc
    SelectObject(this.hdc, this.obm)

    ; Now the bitmap may be deleted
    DeleteObject(this.hbm)

    ; Also the device context related to the bitmap may be deleted
    DeleteDC(this.hdc)

    ; The graphics may now be deleted
    Gdip_DeleteGraphics(this.G)

    ; gdi+ may now be shutdown on exiting the program
    Gdip_Shutdown(this.pToken)
  }
  /*!
    Methods: toString
      Dumps the object to a readable string

    Returns:
      string - dump
  */
  toString() {
    return "RDA_Overlay{hwnd " . this.hwnd . "}"
  }

  /*!
    Method: refresh
      Updates all objects and update window.
  */
  refresh() {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "] objects " . this.objects.length())

    i := 1
    while (i <= this.objects.length()) {
      if (!this.objects[i].update()) {
        this.objects.removeAt(i)
        continue
      }

      i += 1
    }

    ; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
    ; So this will position our gui at (0,0) with the Width and Height specified earlier
    UpdateLayeredWindow(this.hwnd, this.hdc, this.region.x, this.region.y, this.region.w, this.region.h)
  }
  /*!
    Method: clear
      Clears the graphics of a bitmap ready for further drawing

    Returns:
      <RDA_Overlay> - for chaining
  */
  clear() {
    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "]")

    Gdip_GraphicsClear(this.G, 0x00FFFFFF)

    return this
  }
  /*!
    Method: drawImage
      Draws an image into given region

    Parameters:
      imagePath - string - image path
      region - <RDA_ScreenRegion> - region

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawImage(imagePath, region) {
    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . imagePath . ", " . region.toString() . ")")

    pBitmapFile := Gdip_CreateBitmapFromFile(imagePath)
    RDA_Assert(pBitmapFile, "Gdip_CreateBitmapFromFile failed")

    ; Get the width and height of the 1st bitmap
    srcWidth := Gdip_GetImageWidth(pBitmapFile)
    srcHeight := Gdip_GetImageHeight(pBitmapFile)

    Gdip_DrawImage(this.G, pBitmapFile, region.x, region.y, region.w, region.h, 0, 0, srcWidth, srcHeight)
    Gdip_DisposeImage(pBitmapFile)

    return this
  }
  /*!
    Method: drawImageAt
      Draws an image into the overlay at given position

    Parameters:
      imagePath - string - image path
      x - number - destination x coordinates
      y - number - destination y coordinates
      w - number - width, default image width
      h - number - height, default image height

    Returns:
      <RDA_Overlay> - for chaining
  */
  drawImageAt(imagePath, x := 0, y := 0, w := 0, h := 0) {

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . imagePath . ", " . x . ", " . y . ", " . w . ", " . h . ")")

    pBitmapFile := Gdip_CreateBitmapFromFile(imagePath)
    RDA_Assert(pBitmapFile, "Gdip_CreateBitmapFromFile failed")

    ; Get the width and height of the 1st bitmap
    srcWidth := Gdip_GetImageWidth(pBitmapFile)
    srcHeight := Gdip_GetImageHeight(pBitmapFile)
    if (!w) {
      w := srcWidth
    }
    if (!h) {
      h := srcHeight
    }
    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . imagePath . ", " . x . ", " . y . ", " . w . ", " . h . ")")

    Gdip_DrawImage(this.G, pBitmapFile, x, y, w, h, 0, 0, srcWidth, srcHeight)
    Gdip_DisposeImage(pBitmapFile)

    return this
  }
  /*!
    Method: fillRectangle
      Draws an image into the overlay at given position

    Parameters:
      region - <RDA_ScreenRegion> - region
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillRectangle(region, color) {
    return this.fillRectangle4(region.x, region.y, region.w, region.h, color)
  }
  /*!
    Method: fillRectangle4
      Draws an image into the overlay at given position

    Parameters:
      x - number - top/left x coordinate
      y - number - top/left y coordinate
      w - number - width
      h - number - height
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillRectangle4(x, y, w, h, color) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . w . ", " . h . ", " . color . ")")

    pBrush := Gdip_BrushCreateSolid(color)
    Gdip_FillRectangle(this.G, pBrush, x, y, w, h)
    Gdip_DeleteBrush(pBrush)

    return this
  }
  /*!
    Method: borderRectangle
      Draws a rectangle border

    Parameters:
      region - <RDA_ScreenRegion> - region
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderRectangle(region, color, size := 1) {
    return this.borderRectangle4(region.x, region.y, region.w, region.h, color, size)
  }
  /*!
    Method: borderRectangle4
      Draws a rectangle border

    Parameters:
      x - number - top/left x coordinate
      y - number - top/left y coordinate
      w - number - width
      h - number - height
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderRectangle4(x, y, w, h, color, size := 1) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . w . ", " . h . ", " . color . ", " . size . ")")

    pPen := Gdip_CreatePen(0x66ff0000, size)
    Gdip_DrawRectangle(this.G, pPen, x, y, w, h)
    Gdip_DeletePen(pPen)

    return this
  }
  /*!
    Method: fillCircle
      Draws a filled circle into the overlay at given position

    Parameters:
      pos - <RDA_ScreenPosition> - position
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillCircle(pos, color, radius := 1) {
    return this.fillCircle2(pos.x, pos.y, color, radius)
  }
  /*!
    Method: fillCircle2
      Draws a filled circle into the overlay at given position

    Parameters:
      x - number - center x coordinate
      y - number - center y coordinate
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillCircle2(x, y, color, radius := 1) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . color . ", " . radius . ")")

    pBrush := Gdip_BrushCreateSolid(color)
    Gdip_FillEllipse(this.G, pBrush, x - radius, y - radius, radius * 2, radius * 2)
    Gdip_DeleteBrush(pBrush)

    return this
  }
  /*!
    Method: fillCircle
      Draws a border circle into the overlay at given position

    Parameters:
      pos - <RDA_ScreenPosition> - position
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderCircle(pos, color, radius := 1, size := 1) {
    return this.borderCircle2(pos.x, pos.y, color, radius, size)
  }
  /*!
    Method: borderCircle2
      Draws a border circle into the overlay at given position

    Parameters:
      x - number - center x coordinate
      y - number - center y coordinate
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      radius - number - radius
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderCircle2(x, y, color, radius := 1, size := 1) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " color . ", " . radius . ", " . size . ")")

    pPen := Gdip_CreatePen(color, size)
    Gdip_DrawEllipse(this.G, pPen, x - radius, y - radius, radius * 2, radius * 2)
    Gdip_DeletePen(pPen)

    return this
  }
  /*!
    Method: fillEllipse
      Draws a ellipse into the overlay at given region

    Parameters:
      region - <RDA_ScreenRegion> - region
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillEllipse(region, color) {
    return this.fillEllipse4(region.x, region.y, region.w, region.h, color)
  }
  /*!
    Method: fillEllipse
      Draws a ellipse into the overlay at given region

    Parameters:
      x - number - top/left x coordinate
      y - number - top/left y coordinate
      w - number - width
      h - number - height
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF

    Returns:
      <RDA_Overlay> - for chaining
  */
  fillEllipse4(x, y, w, h, color) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . w . ", " . h . ", " . color . ")")

    pBrush := Gdip_BrushCreateSolid(color)
    Gdip_FillEllipse(this.G, pBrush, x, y, w, h)
    Gdip_DeleteBrush(pBrush)

    return this
  }
  /*!
    Method: borderEllipse
      Draws a border ellipse into inside given region

    Parameters:
      region - <RDA_ScreenRegion> - region
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderEllipse(region, color, size := 1) {
    return this.borderEllipse4(region.x, region.y, region.w, region.h, color, size)
  }
  /*!
    Method: borderEllipse4
      Draws a border ellipse into inside given region

    Parameters:
      x - number - center x coordinate
      y - number - center y coordinate
      w - number - width
      h - number - height
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - border size

    Returns:
      <RDA_Overlay> - for chaining
  */
  borderEllipse4(x, y, w, h, color, size := 1) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . w . ", " . h . ", " . color . ", " . size . ")")

    pPen := Gdip_CreatePen(color, size)
    Gdip_DrawEllipse(this.G, pPen, x, y, w, h)
    Gdip_DeletePen(pPen)

    return this
  }
  /*!
    Method: line
      Draws a line

    Parameters:
      src - <RDA_ScreenPosition> - src
      dst - <RDA_ScreenPosition> - dst
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - line width

    Returns:
      <RDA_Overlay> - for chaining
  */
  line(src, dst, color, size := 1) {
    return this.line4(src.x, src.y, dst.x, dst.y, color, size)
  }
  /*!
    Method: line4
      Draws a line

    Parameters:
      x - number - source x coordinate
      y - number - source y coordinate
      x2 - number - destination x coordinate
      y2 - number - destination y coordinate
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
      size - number - line width

    Returns:
      <RDA_Overlay> - for chaining
  */
  line4(x, y, x2, y2, color, size := 1) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . x2 . ", " . y2 . ", " . color . ", " . size ")")

    pPen := Gdip_CreatePen(color, size)
    Gdip_DrawLine(win.G, pPen, x, y, x2, y2)
    Gdip_DeletePen(pPen)

    return this
  }

  /*!
    Method: text
      Draws text bellow given position

    Parameters:
      win - <RDA_Overlay> - overlay win
      text - string - text
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
  */
  text(pos, text, color, font := "Arial", fontSize := 16) {
    return this.text2(pos.x, pos.y, text, color, font, fontSize)
  }
  /*!
    Method: text
      Draws text bellow given position

    Parameters:
      win - <RDA_Overlay> - overlay win
      text - string - text
      color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
  */
  text2(x, y, text, color, font := "Arial", fontSize := 16) {
    local

    RDA_Log_Debug(A_ThisFunc . "[" . this.hwnd . "](" . x . ", " . y . ", " . text . ", " . color . ")")

    pBrush := Gdip_BrushCreateSolid(color)
    ; pPen := Gdip_CreatePen(color, 1)
    pPen := 0
    Gdip_DrawOrientedString(this.G, text, font, fontSize, "", x, y, A_ScreenWidth, 300, 0, pBrush, pPen, 0)
    ; Gdip_DeletePen(pPen)
    Gdip_DeleteBrush(pBrush)
  }
  /*!
    Method: addObject
      Appends obect

    Parameters:
      obj - <RDA_OverlayObject> - overlay object

    Returns:
      <RDA_AutomationOverlay> - for chaining
  */
  addObject(obj) {
    this.objects.push(obj)
    obj.overlayOwner := this

    return this
  }
  /*!
    Method: removeObject
      Removes given obect

    Parameters:
      obj - <RDA_OverlayObject> - overlay object

    Returns:
      bool - if it was removed
  */
  removeObject(obj) {
    idx := RDA_Array_IndexOf(this.objects, obj)
    if (idx > 0) {
      this.objects.removeAt(idx)
      return true
    }

    return false
  }
}

/*!
  Class: RDA_OverlayObject
    (abstract) Base class for overlay objects
*/
class RDA_OverlayObject {
  /*!
    Property: overlayOwner
      overlayOwner - <RDA_AutomationOverlay>
  */
  overlayOwner := 0
  /*!
    Constructor: RDA_OverlayObject
      Creates <RDA_OverlayObject>
  */
  __new() {
  }

  __Delete() {
  }
  /*!
    Method: update
      Updates the object
  */
  update() {
    RDA_Assert(this.overlayOwner, "overlayOwner must be set before calling update")

    return this.draw()
  }
  /*!
    Method: draw
      Draws onto overlay.

    Remarks:
      This need to be overriden
  */
  draw() {
    throw RDA_Exception(A_ThisFunc . " needs to be overriden")
  }
}

/*!
  Class: RDA_OverlayClick
*/
class RDA_OverlayClick extends RDA_OverlayObject {
  pos := 0
  timeout := 0
  /*!
    Constructor: RDA_OverlayClick

    Parameters:
      pos - <RDA_ScreenPosition> | <RDA_WindowPosition> - position
      timeout - number - Timeout, in miliseconds
  */
  __new(pos, timeout := 2000) {
    this.pos := pos
    this.timeout := A_TickCount + timeout
    this.start := A_TickCount
  }

  draw() {
    RDA_Log_Debug(A_ThisFunc)

    if (A_TickCount > this.timeout) {
      return false
    }

    radius := (A_TickCount - this.start) // 100

    pos := this.pos.toScreen()
    ; borderCircle(pos, color, radius := 1, size := 1) {
    this.overlayOwner.borderCircle(pos, 0x66FF0000, radius, 2)

    radius := (A_TickCount - this.start) // 200
    this.overlayOwner.borderCircle(pos, 0x66FF0000, radius, 2)

    return true
  }
}
/*!
  Class: RDA_OverlayCountdown
*/
class RDA_OverlayCountdown extends RDA_OverlayObject {
  /*!
    Constructor: RDA_OverlayCountdown

    Parameters:
      count - number - seconds
  */
  __new(count) {
    this.countdown := A_TickCount + count * 1000
  }
  __Delete() {
  }
  /*!
    Method: draw
      Draws a countdown onto overlay
  */
  draw() {
    RDA_Log_Debug(A_ThisFunc)

    seconds := (this.countdown - A_TickCount) // 1000
    if (seconds > 0) {
      this.overlayOwner.text2(1024, 0, "" . seconds, 0xFF0000000)
      return true
    }

    return false
  }
}
/*!
  Class: RDA_OverlayLayout

  Extends: RDA_OverlayObject

  Example:
    ======= AutoHotKey =======
      automation := new RDA_Automation()
      windows := automation.windows()

      win := windows.findOne({...})
      layout := new RDA_Layout(win)
      layout.fromJsonFile(A_ScriptDir . "\layout.json")

      overlay := new RDA_Overlay(automation)
      overlay.addObject(new RDA_OverlayLayout(layout))
      overlay.refresh()
    ==========================
*/
class RDA_OverlayLayout extends RDA_OverlayObject {
  /*!
    Property:
      <RDA_Layout> - layout
  */
  layout := 0
  /*!
    Constructor: RDA_OverlayLayout
      Creates <RDA_OverlayLayout>

    Parameters:
      layout - <RDA_Layout> - layout
  */
  __new(layout) {
    this.layout := layout
  }

  __Delete() {
  }
  /*!
    Method: draw
      Draws layout onto overlay

    Returns:
      boolean - if it needs to be removed
  */
  draw() {
    loop % this.layout.elements.length() {
      el := this.layout.elements[A_Index]
      el.region.drawFill(this.overlayOwner, 0x33FF00000)
      el.region.drawBorder(this.overlayOwner, 0x66FF00000, 1)
    }

    return true
  }
}

