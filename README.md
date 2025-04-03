# ~Robotnik~ Robotic Desktop Automation in AutoHotKey (rda-ahk)

Automate desktop applications (attended an unattended) in AutoHotKey v1 using:

* Java access bridge for Java applications
* Microsoft UI Automation for Window native application and UWP
* Images for remote application, RDP, Citrix, Horizon (It requires an interactive desktop)
* (OS) Mouse / Keyboard / Screen / Clipboard

## API

[rda-ahk API](https://htmlpreview.github.io/?https://github.com/llafuente/rda-ahk/blob/main/docs/index.html)

## Examples

Wait a mspaint, paint a pixel (click), and close.

```AutoHotKey
#Include dist\rda.ahk

automation := new RDA_Automation()
windows := automation.windows()

win := windows.waitOne({process: "mspaint.exe"})
win.mouseMoveTo(150, 105).click().close()
closePopup := win.waitChild({classNN: "#32770"})
closePopup.sendKeys("n")

; check is closed!
RDA_Assert(closePopup.isAlive() == false)
RDA_Assert(win.isAlive() == false)
```

Fill some values from a java application and expect changes are saved.

```AutoHotKey
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

## Features

* Automate interactively and background apps (Mouse and keyboard)
* Automate by image, pixel colors
* Seamless automation with UI Automation / Java access bridge
* Manage windows, monitor, virtual desktops

## API Terminology / decisions

There are various decisions around how we name things.

Components and Controls are the most common words for UI elements, but as you will see an application has more than that, that's why everything is an *element*.

UIA use Pattern to report what an `element` is capable / operations that can be performed. JAB use the word Interfaces. And a browser ~should~ use `aria-*`. We made a decision to use *pattern* and make an effort to match what UIA does in other APIs.

Each library use their own system to locate elements, that is a mess (API/ergonomics) so we implement a *"small/distilled" version of xPath* and that's how you locate elements!

The API is designed to be *chained*.

* Verbs, `set*` and `expect*` chain to the same type.
* `wait*`, `find*` may chain, it's not guaranteed.
* `is*` and `get*` return another value.
* `os*` may chain. It operates at OS level not UIA/JAB.

The API is built in *layers of functionality* for example a `RDA_Window` will rely on `RDA_keyboard` to `sendKeys` but it will activate the window to ensure the action is performed only in the proper window while `RDA_Keyboard` will just send the keys to the Operating System.

While the main purpose of the library is to automate we include many test functions to ensure that data is saved as expected or to test an application.

*Traceability*. AHK can call a non-existing method or worst, don't call a method at all. Every method/function will leave a trace in the log so you will know what your robot does in any moment and you will be able to perform a proper post-mortem if necessary.

## Patterns

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

List of pattern not implemented: RangeValue, Grid, GridItem, MultipleView, Window, Dock, Table, TableItem, Transform, ScrollItem, ItemContainer, VirtualizedItem, SyncronizedInput, LegacyIAccessible

There are a few differences:

* JAB do not have `setValue` for Value pattern because it just does not exists. A combination of keyboard+mouse shall be used to automate.

* JAB do not have `Scroll` pattern because it does exists, and cannot be mimic because you cannot `setValue` of a scroll item.

* Action pattern is JAB exclusive. JAB elements had many custom operations that are called `action` that expose neat functionality like "copy selected text to clipboard".

## Distribution

To generate the distribution file use:

```cmd
npm run dist
```

* It will append all source files into one
* Include all dependencies
* Remove comments / empty lines

The *default* dist file will *include* our log system.

You can disable the log swapping files: *RDA_Functions_Log.ahk* -> *RDA_Functions_NoLog.ahk* at [./dist.ps1](./dist.ps1) or implement your own see [./src/RDA_Functions_NoLog.ahk](./src/RDA_Functions_NoLog.ahk)

## Documentation

[rda-ahk API documentation](./docs/index.html)

Documentation is generated using [naturaldocs](https://naturaldocs.org/)

To generate the documentation

```cmd
npm run docs
```

## About

Some information about the project.

### Unit test

The project is almost 100% unit tested We can't be sure because AutoHotKey
do not have code coverage capabilities.

### Porting to AutoHotKey v2 ?

There is no plan.

Nevertheless as future proof all AutoHotKey APIs (commands) are encapsulated inside functions so the work should be easy.

Dependencies:

* UIAutomation has a port but We don't know if the API is the same.
* JSON, author says it works
* YUnit, author says it works

We accept volunteers to keep the port runnig.


### Java access bridge

Use the same JRE if possible but the 64 bits version, AHK should be also x64.


### Code quality

No warnings. No variables leaks (good usage of local/global). No globals.

All clases/functions are namespaced: "RDA_*"

If you plan to add any functionality, cover it with a test.

### Future releases

The only mayor platform missing to automate is the browser.

There are two ways:
* Use selenium: Covers everything, add binary dependencies. Possible but not direct.
* Use UIAtomation: Some functionality is degraded, some is just a hack! Possible but not robust.

### Dependencies

* https://github.com/Descolada/UIAutomation

  It will bridge Microsoft UI Automation CPP and AHK

* https://github.com/cocobelgica/AutoHotkey-JSON

  JSON library it's only used for debuggin purposes.

  Optional.

* https://github.com/Uberi/Yunit

  Unit testing.

  Optional.

* https://github.com/marius-sucan/AHK-GDIp-Library-Compilation

  GDIp library. Overlay and debug purposes.

  Optional.
