# [gb-vwf](//github.com/ISSOtm/gb-vwf) demo

This is a project showcasing how to use gb-vwf within a larger project, as well as most of its functionality.

## Building

- [RGBDS](//rgbds.gbdev.io) 0.6.0 or later[^rgbds0.5].
- A POSIX environment with Bash (Linux and macOS qualify; on Windows, WSL or MSYS2 are required).

Simply open a terminal in this directory, and run `./do`.
Open the resulting `vwf.gb` in your favourite GB emulator ([Emulicious](//emulicious.net), [Mesen2](//mesen.ca), or [BGB](//bgb.bircd.org) are recommended), or load it onto your flashcart if you got one!

## Contributing

Please report any issues [on the bug tracker](//github.com/ISSOtm/gb-vwf-demo/issues).

This project uses [Redo](//redo.readthedocs.io/en/latest) as its build system; you should probably use that instead of `./do` if you're planning to hack on it.

[^rgbds0.5]: 0.5.x also works if replacing `-I` with `-i`.
