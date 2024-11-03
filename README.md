# Robotic desktop automation

Automate desktop applications (attended an unattended) using:

* Java access bridge
* Microsoft UI Automation
* Images (It requires an interactive desktop)
* (OS) Mouse / Keyboard / Screen / Clipboard

# Documentation

Documentation is generated using [naturaldocs](https://naturaldocs.org/)

[docs.ps1](./docs.ps1)

# About

Some information about the project.

## AutoHotKey v1

There is no plan to migrate the library to AHK v2,
neverdeless most of AHK API is in functions.ahk,
that's the only code that need to be ported.

UIAutomation has a port but I don't know if the API is the same.

RDA unit tests cover almost 100% api/functionality so it will be easy to
port.

I accept volunteers to keep the port runnig.

## 32 / 64 bits

Keep in mind that automate an application may require to match the running
architecture. A 32 bit app may requires 32 bit AHK.

That's the case of Java acess bridge applications. That may also require to
use the same JRE.

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
