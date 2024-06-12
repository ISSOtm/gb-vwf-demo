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

## License

[![CC0 licensed (public domain)](https://licensebuttons.net/p/zero/1.0/80x15.png)](http://creativecommons.org/publicdomain/zero/1.0/)
This demo's code and assets are dedicated to the public domain.

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  To the extent possible under law, all copyright and related or neighboring rights to
  <span property="dct:title">gb-vwf-demo</span> have been waived.
  This work is published from <span property="vcard:Country" datatype="dct:ISO3166" content="FR" about="https://eldred.fr">France</span>.
</p>

[^rgbds0.5]: 0.5.x also works if replacing `-I` with `-i`.
