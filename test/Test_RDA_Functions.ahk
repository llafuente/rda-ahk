Test_RDA_Functions_CreateFile(file) {
  FileAppend, test, % file
}

class Test_RDA_Functions {
  Begin() {
  }



  Test_RDA_Array_IndexOf() {
    local

    arr := [1, 2, 3]
    arr2 := [5, "xxx", {}, []]

    RDA_Assert(RDA_Array_IndexOf(arr, 1) == 1, "RDA_Array_IndexOf 1 failed")
    RDA_Assert(RDA_Array_IndexOf(arr, 2) == 2, "RDA_Array_IndexOf 2 failed")
    RDA_Assert(RDA_Array_IndexOf(arr, 3) == 3, "RDA_Array_IndexOf 3 failed")
    RDA_Assert(RDA_Array_IndexOf(arr2, "xxx") == 2, "RDA_Array_IndexOf 4 failed")
    RDA_Assert(RDA_Array_IndexOf(arr2, {}) == 0, "RDA_Array_IndexOf 5 failed")
    RDA_Assert(RDA_Array_IndexOf(arr2, []) == 0, "RDA_Array_IndexOf 6 failed")
  }

  Test_RDA_Array_Concat() {
    local

    arr := [1, 2, 3]
    arr2 := [3, 4, 5]

    arr3 := RDA_Array_Concat(arr, arr2)
    tarr3 := [1, 2, 3, 3, 4, 5]

    loop % arr3.length() {
      RDA_Assert(arr3[A_Index] == tarr3[A_Index], "RDA_Array_Concat unexpected value at " . A_Index)
    }
  }

  Test_RDA_Array_Join() {
    local

    RDA_Assert(RDA_Array_Join([1,2,3], ",") == "1,2,3", "RDA_Array_Join 1")
    RDA_Assert(RDA_Array_Join(["a","b","c"], ",") == "a,b,c", "RDA_Array_Join 2")
  }

  Test_RDA_IsArray() {
    local

    RDA_Assert(RDA_IsArray({}) == true, "empty object is an array")
    RDA_Assert(RDA_IsArray({1:1, 2:2, 3:3}) == true, "an object that look like an array is an array")
    RDA_Assert(RDA_IsArray({1:1, 2:2, 3:3, x: 0}) == false, "object with extra properties is not an array")
    RDA_Assert(RDA_IsArray({1:1, 2:2, 4:3}) == false, "need to be a dense array")
    x := {}
    x.push(1)
    RDA_Assert(RDA_IsArray(x) == true, "an object that look like an array is an array 2")
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
