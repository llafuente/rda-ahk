/*!
  Class: TestOpenApp
    Opens and application, wait its windown and closes it on destruction.
*/
class TestOpenApp {
  __New(cmd, searchProcess) {
    run % cmd

    automation := new RDA_Automation()
    windows := automation.windows()
    this.win := windows.waitOne(searchProcess)
  }

  __Delete() {
    this.win.close()
  }
}
