New-Item -Type Directory dist -Force

$outputFile = ".\dist\rda.ahk"

if (Test-Path $outputFile -ne $null) {
  Write-Host "Previous hash: $((Get-FileHash $outputFile).Hash)"
  Remove-Item $outputFile -Force
}


$files = @(
  ".\UIAutomation\Lib\UIA_Constants.ahk",
  ".\UIAutomation\Lib\UIA_Interface.ahk",

  ".\src\RDA_Functions.ahk",
  # CONFIG: choose one or use your own
  ".\src\RDA_Functions_Log.ahk",
  #".\src\RDA_Functions_NoLog.ahk",

  ".\src\RDA_Base.ahk",
  ".\src\RDA_Automation.ahk",
  ".\src\RDA_AutomationBaseElement.ahk",
  ".\src\RDA_ElementTreeNode.ahk",
  ".\src\RDA_AutomationClipboard.ahk",
  ".\src\RDA_AutomationJAB.ahk",
  ".\src\RDA_AutomationJABAccessibleContextInfo.ahk",
  ".\src\RDA_AutomationJABElement.ahk",
  ".\src\RDA_AutomationKeyboard.ahk",
  ".\src\RDA_AutomationMouse.ahk",
  ".\src\RDA_AutomationUIA.ahk",
  ".\src\RDA_AutomationUIAElement.ahk",
  ".\src\RDA_AutomationWindow.ahk",
  ".\src\RDA_AutomationWindows.ahk",
  ".\src\RDA_AutomationWindowSearch.ahk",
  ".\src\RDA_Rectangle.ahk",
  ".\src\RDA_ScreenPosition.ahk",
  ".\src\RDA_ScreenRegion.ahk",
  ".\src\RDA_SearchLimits.ahk",
  ".\src\RDA_Monitors.ahk",
  ".\src\RDA_VirtualDesktops.ahk",
  ".\src\RDA_AutomationLayout.ahk"
  ".\src\RDA_WindowPosition.ahk"
)
$contents = ""
foreach ($file in $files) {
  $contents += Get-Content $file -Encoding UTF8 -Raw
}
#$contents = $contents -replace "(?:\/\*(?:\n|\r|.)*?\*\/)", "`n`n"
#$contents = $contents -replace '(?sm)/\*.*?\*/|^[ \t]*//[^\r\n]*', ""
#$contents = $contents -replace '(?sm)/\*.*?\*/', "" | ? {$_.trim() -ne "" }
$contents = $contents -replace '(?sm)/\*.*?\*/', ""
#$contents = $contents -replace "(?m)^\s*`r`n",''
$contents = $contents -replace "(?m)^\s*`n",''


Set-Content -Path $outputFile -Value $contents -Encoding UTF8
Write-Host "Current hash: $((Get-FileHash $outputFile).Hash)"
