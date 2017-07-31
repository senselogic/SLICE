/*
    This file is part of the Slice distribution.

    https://github.com/senselogic/REDRAW

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Slice is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Slice is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

// == LOCAL

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.file : read, readText, write;
import std.stdio : writeln;
import std.string : endsWith, replace, split, startsWith;

// == GLOBAL

// -- TYPES

class SLICE
{
    bool
        ItIsSilence;
    long
        SampleIndex,
        SampleCount;
}

// ~~

class SOUND
{
    ubyte[]
        ByteArray;
    long
        SampleByteCount,
        SampleCountPerSecond,
        SampleCount;
    SLICE[]
        SliceArray;

    // ~~
    
    enum
        HeaderByteCount = 44;

    // ~~ 
    
    long GetNatural8(
        long byte_index
        )
    {
        return ByteArray[ byte_index ];
    }
    
    // ~~ 
    
    long GetNatural16(
        long byte_index
        )
    {
        return 
            GetNatural8( byte_index ) 
            | ( GetNatural8( byte_index + 1 ) << 8 );
    }

    // ~~

    long GetNatural32(
        long byte_index
        )
    {
        return
            GetNatural8( byte_index )
            | ( GetNatural8( byte_index + 1 ) << 8 )
            | ( GetNatural8( byte_index + 2 ) << 16 )
            | ( GetNatural8( byte_index + 3 ) << 24 );
    }

    // ~~

    void SetNatural32(
        long byte_index,
        long natural
        )
    {
        ByteArray[ byte_index ] = ( natural & 255 ).to!ubyte();
        ByteArray[ byte_index + 1 ] = ( ( natural >> 8 ) & 255 ).to!ubyte();
        ByteArray[ byte_index + 2 ] = ( ( natural >> 16 ) & 255 ).to!ubyte();
        ByteArray[ byte_index + 3 ] = ( ( natural >> 24 ) & 255 ).to!ubyte();
    }
    
    // ~~
    
    long GetByteIndex(
        long sample_index
        )
    {
        return HeaderByteCount + sample_index * 2;
    }
    
    // ~~
    
    long GetSample(
        long sample_index
        )
    {
        long
            sample;

        if ( sample_index >= 0
             && sample_index < SampleCount )
        {
            sample = cast( short )GetNatural16( GetByteIndex( sample_index ) );

            if ( sample < 0 )
            {
                sample = -sample;
            }

            return sample;
        }

        return 0;
    }
        
    // ~~
    
    void ReadFile(
        string file_path
        )
    {
        writeln( "Reading file : ", file_path );
        
        ByteArray = cast( ubyte[] )file_path.read();
        
        if ( GetNatural8( 0 ) == 'R'
             && GetNatural8( 1 ) == 'I'
             && GetNatural8( 2 ) == 'F'
             && GetNatural8( 3 ) == 'F'
             && GetNatural8( 8 ) == 'W'
             && GetNatural8( 9 ) == 'A'
             && GetNatural8( 10 ) == 'V'
             && GetNatural8( 11 ) == 'E'
             && GetNatural8( 12 ) == 'f'
             && GetNatural8( 13 ) == 'm'
             && GetNatural8( 14 ) == 't'
             && GetNatural8( 15 ) == ' '
             && GetNatural16( 20 ) == 1
             && GetNatural16( 22 ) == 1
             && GetNatural16( 32 ) == 2
             && GetNatural16( 34 ) == 16
             && GetNatural8( 36 ) == 'd'
             && GetNatural8( 37 ) == 'a'
             && GetNatural8( 38 ) == 't'
             && GetNatural8( 39 ) == 'a' )
        {
            SampleCountPerSecond = GetNatural32( 24 );
            SampleCount = GetNatural32( 40 ) / 2;
        }
        else
        {
            Abort( "Invalid file format" ); 
        }
    }
    
    // ~~
    
    void WriteFile(
        string file_path,
        long sample_index,
        long sample_count
        )
    {
        SOUND
            sound;
            
        writeln( "Writing file : ", file_path );
            
        sound = new SOUND;
        
        sound.ByteArray 
            = ByteArray[ 0 .. HeaderByteCount ] 
              ~ ByteArray[ GetByteIndex( sample_index ) .. GetByteIndex( sample_index + sample_count ) ];
              
        sound.SetNatural32( 40, sample_count * 2 );
        
        file_path.write( sound.ByteArray );
    }
    
    // ~~
    
    void FindSlices(
        )
    {
        bool
            it_is_silence;
        long
            silence_sample;
        SLICE
            slice;
            
        silence_sample = ( SilenceVolume * 32767 ).to!long();

        SliceArray ~= new SLICE;
        slice = new SLICE;
        
        foreach ( sample_index; 0 .. SampleCount )
        {
            it_is_silence
                = ( GetSample( sample_index ) <= silence_sample
                    && GetSample( sample_index + 1 ) <= silence_sample
                    && GetSample( sample_index + 2 ) <= silence_sample
                    && GetSample( sample_index + 3 ) <= silence_sample );
            
            if ( it_is_silence != slice.ItIsSilence )
            {
                SliceArray ~= slice;

                slice = new SLICE;
                slice.ItIsSilence = it_is_silence;
                slice.SampleIndex = sample_index;
            }

            ++slice.SampleCount;
        }
        
        SliceArray ~= slice;
        SliceArray ~= new SLICE;
    }

    // ~~

    void FilterSlices(
        )
    {
        long
            silence_sample_count,
            slice_index;

        silence_sample_count = ( SilenceDuration * SampleCountPerSecond ).to!long();

        for ( slice_index = 0;
              slice_index < SliceArray.length - 1;
              ++slice_index )
        {
            if ( SliceArray[ slice_index ].ItIsSilence
                 == SliceArray[ slice_index + 1 ].ItIsSilence )
            {
                SliceArray[ slice_index ].SampleCount
                    += SliceArray[ slice_index + 1 ].SampleCount;

                SliceArray = SliceArray[ 0 .. slice_index + 1 ] ~ SliceArray[ slice_index + 2 .. $ ];

                --slice_index;
            }
            else if ( slice_index + 2 < SliceArray.length
                      && !SliceArray[ slice_index ].ItIsSilence
                      && SliceArray[ slice_index + 1 ].ItIsSilence
                      && SliceArray[ slice_index + 1 ].SampleCount < silence_sample_count
                      && !SliceArray[ slice_index + 2 ].ItIsSilence )
            {
                SliceArray[ slice_index ].SampleCount
                    += SliceArray[ slice_index + 1 ].SampleCount
                       + SliceArray[ slice_index + 2 ].SampleCount;

                SliceArray = SliceArray[ 0 .. slice_index + 1 ] ~ SliceArray[ slice_index + 3 .. $ ];

                --slice_index;
            }
        }
    }

    // ~~

    void WriteSlices(
        )
    {
        long
            next_sample_count,
            output_file_index,
            prior_sample_count,
            sample_count,
            sample_index;
        string
            output_file_path;
        string[]
            slice_name_array;
        SLICE
            slice;

        if ( SliceNameFilePath != "" )
        {
            slice_name_array = SliceNameFilePath.readText().replace( "\r", "" ).split( "\n" );
        }

        output_file_index = 0;

        foreach ( slice_index; 0 .. SliceArray.length )
        {
            slice = SliceArray[ slice_index ];

            if ( !slice.ItIsSilence
                 && slice.SampleCount > 0 )
            {
                output_file_path = OutputFilePrefix;

                if ( output_file_index < slice_name_array.length )
                {
                    output_file_path ~= slice_name_array[ output_file_index ];
                }
                else
                {
                    output_file_path ~= ( output_file_index + 1 ).to!string();
                }

                output_file_path ~= ".wav";

                sample_index = slice.SampleIndex;
                sample_count = slice.SampleCount;

                if ( !TrimOptionIsEnabled )
                {
                    prior_sample_count = 0;
                    next_sample_count = 0;

                    if ( slice_index == 1 )
                    {
                        prior_sample_count = SliceArray[ slice_index - 1 ].SampleCount;
                    }
                    else if ( slice_index > 0 )
                    {
                        prior_sample_count = SliceArray[ slice_index - 1 ].SampleCount >> 1;
                    }

                    sample_index -= prior_sample_count;
                    sample_count += prior_sample_count;

                    if ( slice_index == SliceArray.length - 2 )
                    {
                        next_sample_count = SliceArray[ slice_index + 1 ].SampleCount;
                    }
                    else if ( slice_index + 1 < SliceArray.length )
                    {
                        next_sample_count = SliceArray[ slice_index + 1 ].SampleCount >> 1;
                    }

                    sample_count += next_sample_count;
                }


                WriteFile( output_file_path, sample_index, sample_count );

                ++output_file_index;
            }
        }
    }
}

// -- VARIABLES

bool
    TrimOptionIsEnabled;
float
    SilenceDuration,
    SilenceVolume;
string
    InputFilePath,
    OutputFilePrefix,
    SliceNameFilePath;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void ProcessFile(
    )
{
    SOUND
        sound;
        
    sound = new SOUND;
    sound.ReadFile( InputFilePath );
    sound.FindSlices();
    sound.FilterSlices();
    sound.WriteSlices();
}
    
// ~~

void main(
    string[] argument_array
    )
{
    string
        option;
        
    SilenceVolume = 0.001f;
    SilenceDuration = 0.04f;
    TrimOptionIsEnabled = false;
    SliceNameFilePath = "";

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--volume"
             && argument_array.length >= 1 )
        {
            SilenceVolume = argument_array[ 0 ].to!float();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--duration"
                  && argument_array.length >= 1 )
        {
            SilenceDuration = argument_array[ 0 ].to!float();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--trim" )
        {
            TrimOptionIsEnabled = true;
        }
        else if ( option == "--name"
                  && argument_array.length >= 1 )
        {
            SliceNameFilePath = argument_array[ 0 ];

            argument_array = argument_array[ 1 .. $ ];
        }
        else
        {
            PrintError( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 2
         && argument_array[ 0 ].endsWith( ".wav" ) )
    {
        InputFilePath = argument_array[ 0 ];
        OutputFilePrefix = argument_array[ 1 ];
        
        ProcessFile();
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    slice [options] input_file_path output_file_prefix" );
        writeln( "Options :" );
        writeln( "    --volume 0.001" );
        writeln( "    --duration 0.04" );
        writeln( "    --trim" );
        writeln( "    --name \"name_file.txt\"" );
        writeln( "Examples :" );
        writeln( "    slice --volume 0.001 --duration 0.04 input_file.wav OUT/output_file_" );
        writeln( "    slice --volume 0.001 --duration 0.04 --trim input_file.wav OUT/output_file_" );
        writeln( "    slice --volume 0.001 --duration 0.04 --trim --name name_file.txt input_file.wav OUT/" );
        
        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
