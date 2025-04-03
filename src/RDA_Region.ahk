class RDA_Region {
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
