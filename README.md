VGAONOFF: Enable/disable writes to VGA memory from DOS
======================================================

This DOS utility modifies a flag in a VGA register which controls
whether the VGA memory can be updated.  This can be used to suppress
output from command(s) (and then from the `COMMAND.COM` prompt if you
don't re-enable the flag!).


Usage
-----

* `vgaonoff off` disables VGA memory updates.  The cursor will still
  be visible unless a separate utility is used to control it, and it
  will still move around the screen under the control of whatever
  program(s) run after `vgaonoff` returns.

* `vgaonoff on` restores normal behavior.

When invoked as shown above, it generates no output except in case of
an error.  If invoked without any arguments or with an unsupported
argument, it displays a usage message.


Supported hardware and emulators
--------------------------------

A VGA adapter is required.  This utility attempts to detect whether
one is present.  An error is reported if one is not detected.

This has been tested successfully with a small number of VGA adapters
ranging from an older ISA one to the Intel 865G chipset.  It is
assumed that this is fairly standard VGA behavior.

This VGA behavior is _not_ emulated by Bochs 2.7.0, DOSBox 0.74-3,
PCem 16 or QEMU 6.1.0, so there's a good chance it's not emulated by
any emulator or hypervisor.

GitHub issues reporting exceptional behavior - a real VGA adapter that
this utility does _not_ work with or an emulated one that it _does_
work with - are most welcome.


Example
-------

The `example` directory contains a `test.bat` which uses `vgaonoff`
and the accompanying `progress.bat` to display a splash screen with a
progress bar while suppressing output from the accompanying
`spam.bat`.  `spam.bat` uses the Batch Enhancer utility from Norton
Utilities for DOS (tested with version 8) to introduce delays.


Building
--------

This utility was built using Borland's Turbo Assembler 3.1 as included
with Borland C++ 3.1.  `build.bat` can be used to perform the build.


License
-------

VGAONOFF is Copyright 2024 David O'Shea

VGAONOFF is licensed to you under the terms of the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.  See
the `COPYING` file for details.

I'm willing to consider licensing it under a less restrictive license.
Please file a GitHub issue if you would like this, explaining why it
would be useful.
