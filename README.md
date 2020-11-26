# Beets

Beets is a MIDI drum machine that is driven by text files. It works fine but
is fairly inflexible right now: all parts are quantized by default with no
way to humanize anything.

Beets is written in [Crystal](https://crystal-lang.org).

## Installation

First, install the packages needed to compile the `beets` application.

```sh
brew install crystal
brew install portmidi
```

Next, download the `beets` repo, install the required packages (which Crystal
calls "shards"), and compile the `beets` application.

```sh
git clone git@github.com:jimm/beets
cd beets
shards install
shards build
```

## Usage

First, we need to determine the PortMidi **output** device number or name
corresponding to the MIDI input of the synth or sound generation program you
will be using. If you're using software, it must be running for this step.

```sh
bin/beets -l
```

Beets will output information about all of the MIDI inputs and outputs it
can find. Make a note of the correct output device name or number.

Next, create or edit an existing Beets file. Make sure the correct output
device name or number is in the file. See the example files in the
`examples` and the "Beets Files" section below for more information.

Finally, run `beets` and give it the file you've created.

```sh
bin/beets my_beets_file.txt
```

### Options

Run `bin/beets -h` or `bin/beets --help` to see the list of arguments. The
`--output` and `--channel` arguments override whatever is in the Beets file.

## Beets Files

A Beets file is a [YAML](https://yaml.org/) file. It describes everything
needed to play a song which consists of possibly repeated drum patterns.

The start of the file defines which MIDI device to use and how to configure
it, the BPM of the song (right now tempo changes are not supported), and
whether MIDI start, stop, and clock messages are sent along with the drum
notes.

Next, an optional section defines which instrument names map to which MIDI
note numbers. There is a standard built-in list that maps simple names to
standard General MIDI drum note numbers. You can override any of those and
define new names that play any MIDI note.

Patterns are next. Each pattern can be any length and can use any of the
instruments.

At the end of the file is the song. It defines which patterns to play in
what order, including repeats.

Comments can appear anywhere in a Beets file. Comments are lines that start
with '#' and continue to the end of the line. Comments are ignored.

### Setup

These are the fields that make up the "setup" of a Beets YAML file.

#### name

```
name: My Cool Drum Sequence
```

Optional. The sequence name isn't displayed anywhere.

#### bpm

```
bpm: 120
bpm: 88.5
```

Optional. A floating-point number, but the decimal is optional. The default
is 120 BPM.

#### device

```
device: 3
# or
device: The PortMidi Name
```

Required. Either the name or the device number of a PortMidi device. To see
the list of all attached devices that PortMidi can see, run `beets -l` or
`beets --list-devices`.

#### channel

```
channel: 10
```

Optional. The MIDI channel to use when playing the song. The default channel
is 10. That's the default channel that General MIDI uses for drum tracks.

#### bank

```
bank: 1        # Bank MSB 1
bank: 0, 3     # Bank MSB 0, LSB 3
bank: -, 2     # Bank LSB 2
```

Optional. Bank changes are optional. You can specify one or two bank values.
One value sends the bank MSB (most significant byte). Two values must be
separated by whitespace and an optional comma. MSB is first, then LSB. The
bank values must be either '-' (do not send any bank message) or 0-127.

#### program

```
program: 42
```

Optional. The program number must be 0-127.

#### clock

```
clock: on
```

Optional. If you want the MIDI START, STOP, and CLOCK messages to be sent along with
the drum notes, turn the clock on. On values are "on", "yes", and "true". By
default, those messages are not sent.

### Instrument Map

```
instruments:
  - {name: bass drum, note: 36}
  - {name: snare, note: 38}
```

Optional. Adds mappings from instrument names to MIDI note numbers to the
ones already defined by Beets. Instrument names are case-insensitive.

Beets maps all of the General MIDI drum note names to their numbers, but
they are all prefixed with "gm". For example, the lowest General MIDI drum
note is 35 and its name is "Acoustic Base Drum", so Beets maps the name "GM
Acoustic Base Drum" to note 35. Here is the default Beets instrument map:

| Name                  | Note   |
|-----------------------|--------|
| GM Acoustic Bass Drum | 35, C  |
| GM Bass Drum 1        | 36, C# |
| GM Side Stick         | 37, D  |
| GM Acoustic Snare     | 38, D# |
| GM Hand Clap          | 39, E  |
| GM Electric Snare     | 40, F  |
| GM Low Floor Tom      | 41, F# |
| GM Closed Hi-Hat      | 42, G  |
| GM High Floor Tom     | 43, G# |
| GM Pedal Hi-Hat       | 44, A  |
| GM Low Tom            | 45, A# |
| GM Open Hi-Hat        | 46, B  |
| GM Low-Mid Tom        | 47, C  |
| GM Hi Mid Tom         | 48, C# |
| GM Crash Cymbal 1     | 49, D  |
| GM High Tom           | 50, D# |
| GM Ride Cymbal 1      | 51, E  |
| GM Chinese Cymbal     | 52, F  |
| GM Ride Bell          | 53, F# |
| GM Tambourine         | 54, G  |
| GM Splash Cymbal      | 55, G# |
| GM Cowbell            | 56, A  |
| GM Crash Cymbal 2     | 57, A# |
| GM Vibraslap          | 58, B  |
| GM Ride Cymbal 2      | 59, C  |
| GM Hi Bongo           | 60, C# |
| GM Low Bongo          | 61, D  |
| GM Mute Hi Conga      | 62, D# |
| GM Open Hi Conga      | 63, E  |
| GM Low Conga          | 64, F  |
| GM High Timbale       | 65, F# |
| GM Low Timbale        | 66, G  |
| GM High Agogo         | 67, G# |
| GM Low Agogo          | 68, A  |
| GM Cabasa             | 69, A# |
| GM Maracas            | 70, B  |
| GM Short Whistle      | 71, C  |
| GM Long Whistle       | 72, C# |
| GM Short Guiro        | 73, D  |
| GM Long Guiro         | 74, D# |
| GM Claves             | 75, E  |
| GM Hi Wood Block      | 76, F  |
| GM Low Wood Block     | 77, F# |
| GM Mute Cuica         | 78, G  |
| GM Open Cuica         | 79, G# |
| GM Mute Triangle      | 80, A  |
| GM Open Triangle      | 81, A# |

(Note that the offical MIDI spec calls note 42 "Closed Hi Hat", but all the
other hi hat note names use a dash, such as "Open Hi-Hat". As shown in the
table above, Beets calls note 42 "GM Closed Hi-Hat", with the dash.)

### Patterns

```
patterns:
  - name: Intro
    timesig: 4/4
    bars: 4
    parts:
      - instrument: bass drum
        notes: x.x. x.x. x.x. x.x.
      - instrument: snare
        subdiv: 16
        notes: |
          .... x... .... x...
          .... x... .... x.xx
          .... x... .... x...
          .... x... .... x.xx
  - name: Verse
    bars: 16
    parts:
      - instrument: bass drum
        ...
```

TODO finish writing this section

Required. The `patterns` section consists of one or more drum patterns that
plays zero or more parts (instruments). The length of the pattern is
pre-determined, but a pattern can be played more than once (see the "Song"
section below).

### Pattern

```
  - name: Intro
    timesig: 4/4
    bars: 4
    parts:
      - instrument: bass drum
        notes: x.x. x.x. x.x. x.x.
      - instrument: snare
        subdiv: 16
        notes: |
          .... x... .... x...
          .... x... .... x.xx
          .... x... .... x...
          .... x... .... x.xx
```

Optional. A pattern consists of the following fields.

#### Name

Optional string.

#### Timesig

Optional. Default is 4/4.

#### Bars

Required.

#### Parts

TODO improve note entry!!!

Each instrument in a pattern has its own section consisting of the
instrument name, optional subdiv (default is 4, or quarter note)
the instrument and continues until the next instrument starts, the next
pattern starts, or the song starts. As a shortcut, you can use the unique
prefix of the instrument name. For example, if "bass drum" is the only
instrument name that starts with "b" you only have to type "b". If both
"bass drum" and "bongo" are defined, you'd have to use at least "ba" for the
bass drum and "bo" for the bongo.

Only 'x' and '.' are used. Other characters like newlines, spaces between
beats, and '|' characters between bars are ignored.

NOTE: some day Beets might introduce some shortcuts that help write repeated
patterns.

##### Note Velocities

TODO

### Song

TODO

## To Do

- time signature per pattern, default is 4/4

- bpm per chunk or even as a special part instrument so it can change over time?

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/beets/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jim Menard](https://github.com/jimm) - creator and maintainer

## Notes / GUI

### Recording

#### global

bpm / tempo
time sig
num measures

define kit: name and note number per key

assign keys to drums

#### single pattern

name the pattern (default name is "Pattern N")

start recording
tap to record a note
tap 'erase' button to start erasing whatever notes are held down

quantize to 16th, adjustable
quantize on the fly

velocity??? shift and control?

#### chunks

double click left list of patterns to copy pattern to right side
