# Slice

Audio file splitter.

## Features

* Splits an audio file at its silences.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html).

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
--volume 0.0001 : maximum volume for silences (from zero to one)
--duration 0.05 : minimum duration for silences (in seconds)
--trim : remove the silences in the output files
--name slice_name_file_path : use the lines of a text file to name the output files
```

### Examples

```bash
slice --duration 0.05 input_file.wav OUT/output_file_
```

Split the audio file at pauses of at least 50 milliseconds.

```bash
slice --duration 0.05 --trim input_file.wav OUT/output_file_
```

Split the audio file at pauses of at least 50 milliseconds, removing the silences in the output files.

```bash
slice --duration 0.05 --trim--name slice_name_file.txt input_file.wav OUT/output_file_
```

Split the audio file at pauses of at least 50 milliseconds, removing the silences in the output files, using the lines of the "slice_name_file.txt" to name the output files.

## Limitations

Only supports uncompressed mono 16 bits PCM files in Wave format.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.

## Credits

The test file comes from [fromtexttospeech.com](http://www.fromtexttospeech.com).


