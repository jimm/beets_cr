# Beets

Beets is a MIDI drum machine that is driven by text files.

Bard is written in [Crystal](https://crystal-lang.org).

## Installation

First, install the packages needed to compile the `bard` application.

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

## Beets Files

A Beets file describes everything needed to play a song which consists of
possibly repeated drum patterns.

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

Comments can appear anywhere in a Beets file. Comments start with '#' and
continue to the end of the line. Comments and blank lines are ignored.

### Setup

The setup section consists of a number of lines of the form "name: value".
The section is ended when the first pattern is seen.

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

#### bpm

```
bpm: 120
bpm: 88.5
```

Optional. A floating-point number, but the decimal is optional. The default
is 120 BPM.

#### clock

```
clock: on
```

If you want the MIDI START, STOP, and CLOCK messages to be sent along with
the drum notes, turn the clock on. On values are "on", "yes", and "true". By
default, those messages are not sent.

### Instrument Map

TODO

first letters must be unique. maybe use a trie?

### Patterns

```
pattern: Intro
```

Patterns can have any name you want. Any text after "pattern:" becomes the
pattern name. Any text between here and the next "pattern:" or "song:"
belongs to this pattern.

#### Instruments

```
bass drum
x...x...x...x...

qx... x... x... x...


snare
q..x. ..x. ..x.
# after the first two quarter not tests, four eighths
..exxx
```

TODO improve note entry!!!

Each instrument in a pattern has its own section. It starts with the name of
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
