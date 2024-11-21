#SingleInstance

NotificationEventHandler(sender, notificationKind, notificationProcessing, displayString, activityId) {
    ToolTip, % "Sender: " sender.Dump()
        . "`nNotification kind: " notificationKind " (" UIA_Enum.NotificationKind(notificationKind) ")"
      . "`nNotification processing: " notificationProcessing " (" UIA_Enum.NotificationProcessing(notificationProcessing) ")"
      . "`nDisplay string: " displayString
      . "`nActivity Id: " activityId
}

StructureChangedEventHandler(sender, changeType, runtimeId) {
    try ToolTip, % "Sender: " sender.Dump()
        . "`nChange type: " changeType
}

FocusEventHandler(el) {
  try {
    ToolTip, % "Caught event!`nElement name: " el.CurrentName
  }
}


class Test_RDA_Automation {
  Begin() {
  }

  Test_AutomationInit() {
    local
    global RDA_Automation, Yunit

    RDA_Log_Debug(A_ThisFunc)

    Yunit.assert(RDA_Automation.TIMEOUT != 0, "TIMEOUT set")
    Yunit.assert(RDA_Automation.DELAY != 0, "DELAY set")

    automation := new RDA_Automation()

    Yunit.assert(automation.keyDelay != 0, "keyDelay set")
    Yunit.assert(automation.pressDuration != 0, "pressDuration set")
    Yunit.assert(automation.mouseDelay != 0, "mouseDelay set")
    Yunit.assert(automation.actionDelay != 0, "actionDelay set")
    Yunit.assert(automation.mouseSpeed != 0, "mouseSpeed set")
    Yunit.assert(automation.inputMode != "", "inputMode set")
    Yunit.assert(automation.sendMode == "Event", "default sendMode is event")
    automation.setSendMode("Play")
    Yunit.assert(automation.sendMode == "Play", "sendMode changes")

    lastException := 0
    try {
      automation.setSendMode("xxx")
    } catch e {
      lastException := e
    }
    Yunit.assert(lastException.message == "Invalid mode: xxx", "Multiple windows found error")
  }

  End() {
  }
}
