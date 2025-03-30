/*!
  Class: RDA_Overlay
    Creates a window overlay that do not interference with inputs but logs them.
*/
class RDA_Overlay {
  pToken := 0
  hwnd := 0
  hbm := 0
  hdc := 0
  obm := 0
  G := 0
  /*!
    Constructor: RDA_Overlay

    Parameter:
      automation - <RDA_Automation> -
      region - <RDA_ScreenRegion> - default is the primary screen
  */
  __New(automation, region := 0) {
    local
    global RDA_ScreenRegion

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
  }

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
    Method: refresh
      Refresh window
  */
  refresh() {
    RDA_Log_Debug(A_ThisFunc . "(" . this.hwnd . ")")

    ; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
    ; So this will position our gui at (0,0) with the Width and Height specified earlier
    UpdateLayeredWindow(this.hwnd, this.hdc, this.region.x, this.region.y, this.region.w, this.region.h)
  }
  /*!
    Method: drawImage
      Draws a image into the overlay at given position
  */
  drawImage(imagePath, x := 0, y := 0, w := 0, h := 0) {
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

    Gdip_DrawImage(this.G, pBitmapFile, x, y, w, h, 0, 0, srcWidth, srcHeight)
    Gdip_DisposeImage(pBitmapFile)
  }
}

/*!
  Class: RDA_ScreenRegion
    Creates a window overlay that do not interference with inputs but logs them.
*/

/*!
  Method: drawFill
    Draws a colored rectangle

  Parameters:
    win - <RDA_Overlay> - overlay win
    color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
*/
RDA_GDI_ScreenRegion_drawFill(self, win, color) {
  local

  RDA_Log_Debug(A_ThisFunc . "(" . self.toString() . ", " . color . ")")

  pBrush := Gdip_BrushCreateSolid(color)
  Gdip_FillRectangle(win.G, pBrush, self.x, self.y, self.w, self.h)
  Gdip_DeleteBrush(pBrush)
}
/*!
  Method: drawBorder
    Draws a rectangle outline

  Parameters:
    win - <RDA_Overlay> - overlay win
    color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
*/
RDA_GDI_ScreenRegion_drawBorder(self, win, color) {
  local

  RDA_Log_Debug(A_ThisFunc . "(" . self.toString() . ", " . color . ")")

  pPen := Gdip_CreatePen(0x66ff0000, 1)
  Gdip_DrawRectangle(win.G, pPen, self.x, self.y, self.w, self.h)
  Gdip_DeletePen(pPen)
}

/*!
  Method: drawText
    Draw a rectangle

  Parameters:
    win - <RDA_Overlay> - overlay win
    text - string - text
    color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
*/
; TODO RGB Color!
RDA_GDI_ScreenRegion_drawText(self, win, text, color) {
  local

  ; RDA_Log_Debug(A_ThisFunc . "(" . RDA_JSON_stringify(win) . ")")
  RDA_Log_Debug(A_ThisFunc . "(" . self.toString() . ", " . text . ", " . color . ")")

/*
  Font := "Arial"
  Options := "x" . (self.x + 8) . "p y" . (self.y + 8) . "p w" . (self.w * 2) . "p Centre cffff0000 r4 s8 " ; Underline Italic
  Options := "x" . self.x . "p y" . self.y . "p w" . (self.w) . "p Centre vCentre cffff0000 s8 " ; Underline Italic
  Options := "x" . self.x . "p y" . self.y . "p cffff0000 s8" ; Underline Italic
  ;Options := "x" . (self.x + 8) . "p y" . (self.y + 8) . "p w" . (self.w * 2) . "p Left cff000000 r4 s8 " ; Underline Italic
  ;Options := "x" . (self.x + 8) . "p y" . (self.y + 8) . "p Left cff000000 r4 s8 " ; Underline Italic
  ;Gdip_TextToGraphics(win.G, text, Options, Font, self.w, self.h)
  Gdip_TextToGraphics(win.G, text, Options, Font, self.w, self.h)
*/
  pBrushBgr := 0
  pPen := Gdip_CreatePen(color, 1)
  Gdip_DrawOrientedString(win.G, text, "Arial", 10, "", self.x, self.y, self.w, self.h, 0, pBrushBgr, pPen, 1)
  Gdip_DeletePen(pPen)
}

/*!
  Method: drawImageInto
    Draws an image into given region

  Parameters:
    win - <RDA_Overlay> - overlay win
    text - string - text
    color - number - ARGB = Transparency, red, green, blue, 0xFFFFFFFF
*/
; TODO RGB Color!
RDA_GDI_ScreenRegion_drawImageInto(self, win, imagePath) {
  local

  win.drawImage(imagePath, self.x, self.y, self.w, self.h)
}


RDA_ScreenRegion.drawFill := Func("RDA_GDI_ScreenRegion_drawFill")
RDA_ScreenRegion.drawBorder := Func("RDA_GDI_ScreenRegion_drawBorder")
RDA_ScreenRegion.drawText := Func("RDA_GDI_ScreenRegion_drawText")
RDA_ScreenRegion.drawImageInto := Func("RDA_GDI_ScreenRegion_drawImageInto")
