/*!
  class: RDA_ImageSearchResult
    Automation a window
*/
class RDA_ImageSearchResult extends RDA_ScreenRegion {
  image := 0
  /*!
    Constructor: RDA_AutomationWindow

    Parameters:
      automation - <RDA_Automation> - Automation config
      x - number - x coordintate
      y - number - y coordintate
      imagePath - string - image path
  */
  __New(automation, x, y, imagePath) {
    local
    global RDA_ScreenPosition, RDA_Rectangle

    this.image := imagePath
    cachedImg := RDA_Image_cache(imagePath)
    this.origin := new RDA_ScreenPosition(automation, x, y)
    this.rect := new RDA_Rectangle(automation, cachedImg.width, cachedImg.heght)
  }
}
