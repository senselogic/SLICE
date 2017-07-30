#!/bin/sh
set -x
../slice --duration 0.05 input_file.wav OUT/output_file_
../slice --duration 0.05 --trim input_file.wav OUT/trimmed_output_file_
../slice --duration 0.05 --trim --name slice_name_file.txt input_file.wav OUT/
