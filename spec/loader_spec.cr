require "./spec_helper"
require "../src/beets/loader"
require "../src/beets/player"

TESTFILE = "spec/testfile.yaml"
TEMPFILE = "/tmp/beets_testfile.yaml"

class TestOutputStream < OutputStream
  def self.open(output_device_num : Int32, output_driver_info : Int32*? = nil,
                buffer_size : Int32 = 1024,
                time_proc : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                time_info : (Void* -> LibPortMIDI::PmTimestamp)? = nil,
                latency : Int32 = 0) : OutputStream
    new()
  end

  def initialize
    @stream = nil.as(LibPortMIDI::Stream)
  end
end

class TestLoader < Loader
  def output_stream_from(name_or_id) : OutputStream
    return TestOutputStream.new
  end
end

def test_yaml
  File.open(TESTFILE) { |file| YAML.parse(file) }
end

macro with_tempfile(yaml)
  with tempfile yield
  tmpfile.delete
end

describe Loader do
  it "loads the simple example properly" do
    player = TestLoader.new.load(TESTFILE, nil, nil, nil)
    player.song_name.should eq "Test File"
    player.bpm.should eq 86.8
    player.channel.should eq 1
    player.bank_msb.should eq 1
    player.bank_lsb.should be_nil
    player.program.should eq 10
    player.output_clock.should be_true
    player.drum_kit.instruments["bass drum"].should eq 36

    player.patterns.size.should eq 1
    pat = player.patterns[0]
    pat.name.should eq "My First Pattern"
    pat.time_signature.beats_per_bar.should eq 3
    pat.time_signature.beat_unit.should eq 4
    pat.num_bars.should eq 4

    pat.notes[0].should eq [36, 42 + 0x80] # second note is accented
    pat.notes[1].should be_empty
    pat.notes[TICKS_PER_BEAT].should eq [38, 42 + 0x80]
    pat.notes[TICKS_PER_BEAT * 3].should eq [38, 46 + 0x80]

    player.chunks.size.should eq 1
    chunk = player.chunks[0]
    chunk.play_times.should eq 4
    chunk.pattern.should eq pat
  end

  it "falls back to default values for many things" do
    yaml = test_yaml()
    %w(bpm channel bank program clock).each do |key|
      yaml.as_h.delete(key)
    end
    tmpfile = File.tempfile("beets")
    File.write(tmpfile.path, YAML.dump(yaml))
    tmpfile.rewind

    player = TestLoader.new.load(tmpfile.path, nil, nil, nil)
    player.bpm.should eq 120.0
    player.channel.should eq DEFAULT_DRUM_CHANNEL
    player.bank_msb.should be_nil
    player.bank_lsb.should be_nil
    player.program.should be_nil
    player.output_clock.should be_false

    tmpfile.delete
  end

  it "uses overrides passed in to load" do
    player = TestLoader.new.load(TESTFILE, nil, 3, nil)
    player.channel.should eq 3
    player.bpm.should eq 86.8
  end
end
