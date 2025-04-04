Test_Kill_Processes(windows, searchObject) {
  apps := windows.find(searchObject, true)
  loop % apps.length() {
    apps[A_Index].close()
  }
}

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


ArrayDiff(arr1, arr2) {
  local diff, i, found, j
  diff := []
  loop % arr1.Length() {
    i := A_Index
    found := false
    loop % arr2.Length() {
      j := A_Index
      if (arr1[i] == arr2[j]) {
        found := true
      }
    }
    if (!found) {
      diff.Push(arr1[i])
    }
  }

  loop % arr2.Length() {
    i := A_Index
    found := false
    loop % arr1.Length() {
      j := A_Index
      if (arr2[i] == arr1[j]) {
        found := true
      }
    }
    if (!found) {
      diff.Push(arr2[i])
    }
  }

  return diff
}
