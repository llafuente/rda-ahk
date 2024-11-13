#SingleInstance Force
FileAppend, Test start!`n, *

; dependencies
#Include ..\Yunit\Yunit.ahk
#Include ..\Yunit\StdOut.ahk
#Include ..\Yunit\JUnit.ahk
#Include ..\Yunit\OutputDebug.ahk
#include ..\UIAutomation\Lib\UIA_Constants.ahk
#include ..\UIAutomation\Lib\UIA_Interface.ahk
#include ..\JSON\JSON.ahk

; RDA library
#include ..\src\RDA_Functions.ahk
#include ..\src\RDA_Functions_Log.ahk
#include ..\src\RDA_Base.ahk


#include ..\src\RDA_Automation.ahk
#include ..\src\RDA_AutomationBaseElement.ahk
#include ..\src\RDA_AutomationClipboard.ahk
#include ..\src\RDA_AutomationJAB.ahk
#include ..\src\RDA_AutomationJABAccessibleContextInfo.ahk
#include ..\src\RDA_AutomationJABElement.ahk
#include ..\src\RDA_AutomationKeyboard.ahk
#include ..\src\RDA_AutomationMouse.ahk
#include ..\src\RDA_AutomationUIA.ahk
#include ..\src\RDA_AutomationUIAElement.ahk
#include ..\src\RDA_AutomationWindow.ahk
#include ..\src\RDA_AutomationWindows.ahk
#include ..\src\RDA_AutomationWindowSearch.ahk
#include ..\src\RDA_Rectangle.ahk
#include ..\src\RDA_ScreenPosition.ahk
#include ..\src\RDA_ScreenRegion.ahk

#Include Test_RDA_Automation.ahk
#Include Test_RDA_Region.ahk
#Include Test_RDA_AutomationWindows.ahk
#Include Test_RDA_Keyboard.ahk
#Include Test_RDA_Mouse.ahk
#Include Test_RDA_Pixel.ahk
#Include Test_RDA_Clipboard.ahk
#Include Test_RDA_Image.ahk
#Include Test_RDA_UIA.ahk
#Include Test_RDA_XPath.ahk
#Include Test_RDA_JAB.ahk

#SingleInstance
#Warn All, StdOut ; Enable every type of warning, and displayed in a MsgBox

Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Automation)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Region)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_AutomationWindows)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Keyboard)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Mouse)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Pixel)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Clipboard)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_Image)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_UIA)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_XPath)
Yunit.Use(YunitStdOut, YunitJUnit, YunitOutputDebug).Test(Test_RDA_JAB)

ExitApp 0

F12::ExitApp
