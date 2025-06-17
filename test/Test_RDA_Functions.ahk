Test_RDA_Functions_CreateFile(file) {
  FileAppend, test, % file
}

class Test_RDA_Functions {
  Begin() {
  }



  Test_15_WaitFile() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    file := A_ScriptDir . "\wait-file.txt"
    try {
      FileDelete, % file
    } catch e {
    }


    ; false case
    startTime := A_TickCount
    Yunit.assert(!RDA_File_WaitExist(file, 500, 250), "file don't exist")
    Yunit.assert(A_TickCount - startTime > 400, "(wait error) We wait some time")

    ; true case
    createFile := Func("Test_RDA_Functions_CreateFile").Bind(file)
    SetTimer % createFile, 1000

    startTime := A_TickCount
    Yunit.assert(RDA_File_WaitExist(file, 2000, 250), "file exist 1s later")
    Yunit.assert(A_TickCount - startTime > 900, "(wait ok) We wait some time")

    FileDelete, % file
  }

  End() {
  }
}
