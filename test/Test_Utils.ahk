Test_Kill_Processes(windows, searchObject) {
  apps := windows.find(searchObject, true)
  loop % apps.length() {
    apps[A_Index].close()
  }
}
