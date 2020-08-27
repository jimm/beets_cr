NANOSECS_PER_SEC = 1_000_000_000

class TimeSignature
  property beats_per_bar : Int32 = 4
  property beat_unit : Int32 = 4 # 1 = whole, 8 = eighth
end

# Notes may be accented or unaccented. Unaccented note numbers are unchanged
# MIDI note numbers. Accented note numbers have their high eighth bit set.
class Pattern
  property name : String
  property time_signature : TimeSignature = TimeSignature.new
  property num_bars : Int32
  property notes : Array(Array(UInt8))

  def initialize(@name, @num_bars)
    # FIXME hard-coded number of beats per bar
    @notes = Array.new(ticks_length) { |a| a = [] of UInt8 }
  end

  def ticks_length
    @num_bars * 4 * TICKS_PER_BEAT
  end
end

class Chunk
  property pattern : Pattern
  property play_times : Int32

  def initialize(@pattern, @play_times)
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
  property chunks : Array(Chunk) = [] of Chunk

  def initialize(@output_stream : OutputStream)
  end

  def play
    tick_span = Time::Span.new(nanoseconds: (NANOSECS_PER_SEC / (bpm * 24.0 / 60.0)).to_i64)
    note_off_span = Time::Span.new(nanoseconds: 3000)
    on_status = NOTE_ON + channel
    off_status = NOTE_OFF + channel

    chunks.each do |chunk|
      pattern = chunk.pattern
      chunk.play_times.times do |_|
        start_nanosecs = Time.monotonic

        t = start_nanosecs
        pattern.notes.each do |notes|
          if notes.empty?
            t += tick_span
            next
          end

          wait_until(t)
          notes.each { |note| @output_stream.write_short(on_status, unaccented(note), velocity(note)) }
          wait_until(t + note_off_span) # wait one millisecond then send note off
          notes.each { |note| @output_stream.write_short(off_status, unaccented(note), 0) }

          t += tick_span
        end

        # Wait for end of full length of pattern
        wait_until(start_nanosecs + tick_span * pattern.ticks_length)
      end
    end
  end

  def wait_until(goal_time : Time::Span)
    now = Time.monotonic
    return if now >= goal_time
    sleep(goal_time - now)
  end

  def accented(note_num)
    note_num | 0x80
  end

  def unaccented(note_num)
    note_num & 0x7f
  end

  def accented?(note_num)
    (note_num & 0x80) != 0
  end

  def velocity(note_num)
    accented?(note_num) ? 127_u8 : 64_u8
  end

  def instrument_note_number(name)
    name = name.downcase
    GM_DRUM_NOTE_NAMES.each_with_index do |gm_name, i|
      return (i + GM_DRUM_NOTE_LOWEST).to_u8 if "gm #{gm_name}".downcase == name
    end
    instruments.keys.each do |inst_name|
      return instruments[inst_name] if inst_name.downcase == name
    end
    raise "can not find instrument named #{name}"
  end
end
