# Robotic desktop automation

Automate desktop applications (attended an unattended) in AutoHotKey v1 using:

* Java access bridge
* Microsoft UI Automation
* Images (It requires an interactive desktop)
* (OS) Mouse / Keyboard / Screen / Clipboard

# Examples

Wait a mspaint, write a pixel (click), and close.

```ahk
#Include dist\rda.ahk

automation := new RDA_Automation()
windows := automation.windows()

win := windows.waitOne({process: "mspaint.exe"})
win.mouseMoveTo(150, 105).click().close()
closePopup := win.waitChild({classNN: "#32770"})
; closePopup.mouseMoveTo(200, 110).click()
closePopup.sendKeys("n")
```

Fill some values from a java application and expect changes are saved.

```ahk
#Include dist\rda.ahk

automation := new RDA_Automation()
windows := automation.windows()

win := windows.waitOne({process: "java.exe"})
winElement := win.asJABElement()

winElement.findOne("//Text[@name=""Username:""]")
  .setValue("JohnDoe").expectValue("JohnDoe")

winElement.findOne("//Text[@name=""Password:""]")
  .setPassword("admin").expectValue("admin")

winElement.findOne("//CheckBox[@name=""Remember me:""]")
  .ensureChecked("admin") ; <-- ensure is in fact set + expect

winElement.findOne("//PushButton[@name=""Login""]")
  .click()
```

# API Terminology / decisions

There are various decisions around how we name things.

Components and Controls are the most common words for UI elements, but as you will see an application has more than that, that's why everything is an `element`.

UIA use Pattern to report what the `element` is capable / operations that can be performed. JAB use the word Interfaces. And a browser use `aria-role` (or a combination of attributes). We made a decision to use `pattern` and make an effort to match what UIA does in the rest.

Each library use their own system to locate elements, that are a mess (API/ergonomics) so we implement a "small/reduce" version of xPath and that's how you locate elements!

The API is designed to be chained.

* Verbs, `set*` and `expect*` chain to the same type.
* `wait*`, `find*` may chain, it's not guaranteed.
* `is*` and `get*` return another value.
* `os*` may chain. It operates at OS level not UIA/JAB.

The API is built in layers of functionality for example a `RDA_Window` will rely on `RDA_keyboard` to `sendKeys` but it will activate the window to ensure the action is performed only in the proper window while `RDA_Keyboard` will just send the keys to the Operating System.

While the main purpose of the library is to automate we include many test functions to ensure that data is saved as expected or to test an application.

# Patterns

Here there is a quick table of what operations will be available for each pattern.

| Pattern               | UIA                   | JAB                   |
| --------------------- | --------------------- | --------------------- |
| Value                 | set/getValue          | getValue              |
| Text                  | set/getValue          | set/getValue          |
| SelectionItem         | select/isSelected     | select/isSelected     |
| Invoke                | click                 | click                 |
| Toggle                | toggle/isChecked      | toggle/isChecked      |
| Selection             | getSelected           | getSelected           |
| ExpandCollapse*       | expand/collapse       | expand/collapse       |
| Scroll*               |                       |                       |
| Action                |                       | getActions/doActions  |

* In the TODO list

List of pattern not implemented: RangeValue, , Grid, GridItem, MultipleView, Window, Dock, Table, TableItem, Transform, ScrollItem, ItemContainer, VirtualizedItem, SyncronizedInput, LegacyIAccessible

There are a few differences:

* JAB do not have `setValue` for Value pattern because it just does not exists. A combination of keyboard+mouse shall be used to automate.

* JAB do not have `Scroll` pattern because it does exists, and cannot be mimic because you cannot `setValue` of a scroll item.

* Action pattern is JAB exclusive. JAB elements had many custom operations that are called `action` that expose neat functionality like "copy selected text to clipboard".

# Distribution

To generate the distribution file use:

```cmd
npm run dist
```

* It will append all source files into one
* Include all dependencies
* Remove comments / empty lines

The *default* dist file will *include* our log system.

You can disable the log by using: *RDA_Functions_NoLog.ahk* or implement your own see [RDA_Functions_Log.ahk](./src/RDA_Functions_NoLog.ahk)

# Documentation

[rda-ahk API documentation](./docs/index.html)

Documentation is generated using [naturaldocs](https://naturaldocs.org/)

To generate the documentation

```cmd
npm run docs
```

# About

Some information about the project.

## Unit test

The project is almost 100% unit tested I can't be sure because AutoHotKey
do not have code coverage capabilities.

## Porting to AutoHotKey v2 ?

There is no plan.

Neverdeless as future proof all AutoHotKey APIs (commands) are encapsulated inside functions so the work should be easy.

Dependencies:

* UIAutomation has a port but I don't know if the API is the same.
* JSON, author says it works
* YUnit, author says it works

I accept volunteers to keep the port runnig.


## Java access bridge

Use the same JRE if possible but the 64 bits version.


## Code quality

No warnings. No variables leaks (good usage of local/global).

All clases/functions are namespaced: "RDA_*"

If you plan to add any functionality, cover it with a test.

## Future releases

The only mayor platform to automate missing is the browser.

There are two ways:
* Use selenium: Covers everything, add binary dependencies. Possible but not direct.
* Use UIAtomation: Some functionality is degraded, some is just a hack! Possible but not robust.

## Dependencies

* https://github.com/Descolada/UIAutomation
  It will bridge Microsoft UI Automation CPP and RDA

* https://github.com/cocobelgica/AutoHotkey-JSON
  JSON library it's only used for debuggin purposes.
  Only one function uses it, its optional.

* https://github.com/Uberi/Yunit
  Unit testing.
