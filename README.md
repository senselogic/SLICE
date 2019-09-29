![](https://github.com/senselogic/SLICE/blob/master/LOGO/slice.png)

# Slice

Audio file splitter.

## Features

* Splits an audio file at its silences.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (choosing the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 slice.d
```

## Command line

```bash
slice [options] input_file_path output_file_prefix
```

## Options

```
--volume 0.001 : maximum volume for silences (between 0 and 1)
--duration 0.04 : minimum duration for silences (in seconds)
--trim : remove the silences in the output files
--name name_file_path : use the lines of a text file to name the output files
```

### Examples

```bash
slice --volume 0.001 --duration 0.04 input_file.wav OUT/output_file_
```

Splits the input file at each silence of at least 40 milliseconds.

```bash
slice --volume 0.001 --duration 0.04 --trim input_file.wav OUT/output_file_
```

Splits the input file at each silence of at least 40 milliseconds, removing them in the output files.

```bash
slice --volume 0.001 --duration 0.04 --trim --name name_file.txt input_file.wav OUT/output_file_
```

Splits the input file at each silence of at least 40 milliseconds, removing them in the output files, named from the lines of the text file.

## Limitations

Only supports mono 16-bit PCM audio files in WAV format.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.

## Credits

The test file comes from [fromtexttospeech.com](http://www.fromtexttospeech.com).


