require "yaml"
require "port_midi"
require "./midi_consts"
require "./player"

class Loader
  def initialize
    @player = Player.new(OutputStream.new(nil.as(LibPortMIDI::Stream))) # will be replaced on #load
  end

  # Parses `path` and returns a Player.
  def load(path : String, device_name_or_id : String?, channel : UInt8?, bpm : Float64?, transpose : Int32?)
    yaml = File.open(path) { |file| YAML.parse(file) }

    @player = Player.new(output_stream_from(device_name_or_id || yaml["device"]))
    @player.song_name = yaml["name"].as_s
    @player.clock.bpm = load_bpm(yaml, bpm)
    @player.channel = load_channel(yaml, channel)
    @player.bank_msb, @player.bank_lsb, @player.program = *load_bank_and_pc(yaml)

    val = yaml["clock"]?
    @player.output_clock = val.as_bool if val

    @player.transpose = load_transpose(yaml, transpose)

    instruments = yaml["instruments"]?
    if instruments
      kit = @player.drum_kit
      instruments.as_a.each do |inst|
        kit.add_instrument(inst["name"].as_s, inst["note"].as_i.to_u8)
      end
    end

    load_patterns(yaml["patterns"].as_a)

    yaml["song"].as_a.each do |chunk|
      @player.chunks << Chunk.new(find_pattern(chunk["pattern"].as_s), chunk["times"].as_i)
    end

    @player
  end

  private def load_bpm(yaml, bpm)
    return bpm if bpm
    val = yaml["bpm"]?
    return 120.0 unless val
    val.as_f? || val.as_i.to_f
  end

  private def load_channel(yaml, channel)
    return channel if channel
    val = yaml["channel"]?
    return DEFAULT_DRUM_CHANNEL unless val
    val.as_i.to_u8 - 1_u8
  end

  # Returns an array of three UInt8? values: bank msb, bank lsb, and pc.
  private def load_bank_and_pc(yaml)
    msb : UInt8? = nil
    lsb : UInt8? = nil
    pc : UInt8? = nil

    bank = yaml["bank"]?
    if bank
      msb = bank["msb"]? ? bank["msb"].as_i.to_u8 : nil
      lsb = bank["lsb"]? ? bank["lsb"].as_i.to_u8 : nil
    end

    pc_val = yaml["program"]?
    pc = pc_val ? pc_val.as_i.to_u8 : nil

    {msb, lsb, pc}
  end

  private def load_transpose(yaml, transpose)
    return transpose if transpose

    val = yaml["transpose"]?
    val ? val.as_i : 0
  end

  private def load_patterns(patterns : Array(YAML::Any))
    patterns.each do |pat|
      pattern = Pattern.new(pat["name"].to_s, pat["bars"].as_i)

      val = pat["timesig"]?
      if val
        nums = val.as_s.split("/").map(&.to_i)
        pattern.time_signature.beats_per_bar = nums[0]
        pattern.time_signature.beat_unit = nums[1]
      end

      @player.patterns << pattern
      pat["parts"].as_a.each do |part|
        note_num = @player.drum_kit.instrument_note_number(part["instrument"].as_s)
        val = part["subdiv"]?
        subdiv = val ? val.as_i : 4
        load_notes(pattern, part, subdiv, note_num, part["notes"].as_s)
      end
    end
  end

  private def load_notes(pattern, part, subdiv, note_num, notes)
    # FIXME 4 should be num beats per measure, I think
    ticks = ((4.0 / subdiv) * TICKS_PER_BEAT).to_i
    offset = 0
    notes.gsub(/[^\.xX]/, "").each_char do |note|
      raise "pattern #{pattern.name} part #{part["instrument"]} has too many notes" if offset >= pattern.ticks_length
      case note
      when 'x'
        pattern.notes[offset] << Pattern.unaccented(note_num)
      when 'X'
        pattern.notes[offset] << Pattern.accented(note_num)
      end
      offset += ticks
    end
  end

  private def find_pattern(pattern_name)
    compare_pattern_name = pattern_name.downcase
    @player.patterns.each do |pat|
      return pat if pat.name.downcase == compare_pattern_name
    end
    raise "song: did not find pattern named #{pattern_name} (available: #{@player.patterns.map(&.name).join(", ")})"
  end

  protected def output_stream_from(device_id : Int32)
    OutputStream.open(device_id)
  end

  protected def output_stream_from(name : String)
    begin
      return output_stream_from(name.to_i)
    rescue
    end

    devices = (0...PortMIDI.count_devices)
      .map { |i| PortMIDI.get_device_info(i) }
    name = name.downcase
    found = devices.dup.find do |dev|
      dev.output? && dev.name.downcase == name
    end
    if found
      return OutputStream.open(devices.index(found).as(Int32))
    else
      num = name.to_i
      return OutputStream.open(num)
    end
  end

  protected def output_stream_from(name_or_id : YAML::Any) : OutputStream
    return output_stream_from(name_or_id.as_s)
  end
end
