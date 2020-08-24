require "yaml"
require "port_midi"

# This is how long we wait before waking up to see if there is more work.
# MIDI clocks run at 24 tics per beat. Let's say our maximum allowed BPM is
# 240. That's four beats per second, which is 96 tics per second. We want to
# at least double that (Nyquist frequency!) so let's say 200 wake-ups per
# second. That's 5 millisecs or 5,000,000 nanoseconds per wake-up.
WAIT_NANOSECS = 5_000_000

class Pattern
end

class Chunk
  def initialize(@pattern : Pattern, @play_times : Int32)
  end
end

class Player
  property song_name : String?
  property bpm : Float64 = 120.0
  property channel : UInt8 = 9_u8
  property bank_msb : UInt8?
  property bank_lsb : UInt8?
  property program : UInt8??
  property output_clock : Bool = false
  property instruments : Hash(String, UInt8) = {} of String => UInt8
  property patterns : Array(Pattern) = [] of Pattern
  property arrangement : Array(Chunk)

  # Parses `path` and returns a Player.
  def self.from_file(path)
    yaml = File.open(path) { |file| YAML.parse(file) }
    device_id = find_device_id(yaml["device"])

    player = Player.new(OutputStream.open(device_id))
    player.song_name = yaml["name"].as_s
    player.bpm = yaml["bpm"].as_f if yaml["bpm"]
    player.channel = yaml["channel"] ? yaml["channel"].as_i.to_u8 - 1_u8 : 9_u8
    bank = yaml["bank"]
    if bank
      player.bank_msb = bank["msb"].as_i.to_u8
      player.bank_lsb = bank["lsb"].as_i.to_u8
    end
    player.program = yaml["program"].as_i.to_u8 if yaml["program"]
    player.output_clock = yaml["clock"].as_bool if yaml["clock"]
    instruments = yaml["instruments"]
    if instruments
      instruments.as_a.each do |inst|
        player.instruments[inst["name"].as_s] = inst["note"].as_i.to_u8
      end
    end

    # TODO patterns

    song.as_a.each do |chunk|
      arrangement << Chunk.new(find_pattern(chunk["pattern"].as_s), chunk["times"].as_i)
    end

    puts player # DEBUG
    player
  end

  def self.find_device_id(name_or_id) : Int32
    output_devices = (0...PortMIDI.count_devices)
      .map { |i| PortMIDI.get_device_info(i) }
      .select!(&.input?)
    name_matches = output_devices.dup.select! { |dev| dev.name.downcase == name_or_id }
    name_matches.size == 1 ? output_devices.index(name_matches[0]).as(Int32) : name_or_id.to_s.to_i
  end

  def initialize(@output_stream : OutputStream)
  end

  def play
    wait_span = Time::Span.new(nanoseconds: WAIT_NANOSECS)
    # sleep(wait_span)
  end
end
