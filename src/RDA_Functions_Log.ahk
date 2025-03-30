RDA_Log := FileOpen(A_ScriptDir . "\latest.txt", "w", "UTF-8")
RDA_Log_Level := 3

OnExit("RDA_OnExit")
RDA_OnExit(ExitReason, ExitCode) {
  global RDA_Log
  RDA_Log.write("ExitReason = " . ExitReason . " ExitCode = " . ExitCode)
  RDA_Log.close()
}
/*!
  Function: RDA_Log_Error
    Log an error (level 1)

  Parameters:
    input - any - input
*/
RDA_Log_Error(input) {
  local
  global RDA_Log

  FormatTime, d, A_Now, yyyy/MM/dd HH:mm:ss

  RDA_Log.write(d . " [ERR]" . (IsObject(input) ? RDA_JSON_stringify(input, 0, 2) : input) . "`n")
  RDA_Log.read(0)
}
/*!
  Function: RDA_Log_Info
    Log an info (level 2)

  Parameters:
    input - any - input
*/
RDA_Log_Info(input) {
  local
  global RDA_Log, RDA_Log_Level
  if (RDA_Log_Level > 1) {
    FormatTime, d, A_Now, yyyy/MM/dd HH:mm:ss

    RDA_Log.write(d . " [INF]" . (IsObject(input) ? RDA_JSON_stringify(input, 0, 2) : input) . "`n")
    RDA_Log.read(0)
  }
}
/*!
  Function: RDA_Log_Debug
    Log an debug (level 3)

  Parameters:
    input - any - input
*/
RDA_Log_Debug(input) {
  local
  global RDA_Log, RDA_Log_Level

  if (RDA_Log_Level > 2) {
    FormatTime, d, A_Now, yyyy/MM/dd HH:mm:ss

    RDA_Log.write(d . " [DBG]" . (IsObject(input) ? RDA_JSON_stringify(input, 0, 2) : input) . "`n")
    RDA_Log.read(0)
  }
}
