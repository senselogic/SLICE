#!/bin/sh
set -x
../slice --volume 0.001 --duration 0.04 input_file.wav OUT/output_file_
../slice --volume 0.001 --duration 0.04 --trim input_file.wav OUT/trimmed_output_file_
../slice --volume 0.001 --duration 0.04 --trim --name name_file.txt input_file.wav OUT/
