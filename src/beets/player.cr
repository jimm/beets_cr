require "./chunk"
require "./pattern"
require "./drum_kit"
require "./clock"
require "./midi_consts"

NANOSECS_PER_SEC = 1_000_000_000
NOTE_OFF_SPAN    = Time::Span.new(nanoseconds: 3000)

class Player
  property song_name : String?
  property channel : UInt8 = 9_u8
  property bank_msb : UInt8?
  property bank_lsb : UInt8?
  property program : UInt8??
  property output_clock : Bool = false
  property drum_kit : DrumKit = DrumKit.new
  property patterns : Array(Pattern) = [] of Pattern
  property chunks : Array(Chunk) = [] of Chunk
  property clock

  def initialize(@output_stream : OutputStream)
    @clock = Clock.new(@output_stream)
  end

  def play
    on_status = NOTE_ON + channel
    off_status = NOTE_OFF + channel

    clock.start if @output_clock
    chunks.each do |chunk|
      pattern = chunk.pattern
      chunk.play_times.times do |_|
        start_nanosecs = Time.monotonic

        t = start_nanosecs
        pattern.notes.each do |notes|
          if notes.empty?
            t += clock.bpm_tick_span
            next
          end

          wait_until(t)
          notes.each { |note| @output_stream.write_short(on_status, unaccented(note), velocity(note)) }
          wait_until(t + NOTE_OFF_SPAN)
          notes.each { |note| @output_stream.write_short(off_status, unaccented(note), 0) }

          t += clock.bpm_tick_span
        end

        # Wait for end of full length of pattern
        wait_until(start_nanosecs + @clock.bpm_tick_span * pattern.ticks_length)
      end
    end
    clock.stop if @output_clock
  end

  def wait_until(goal_time : Time::Span)
    now = Time.monotonic
    while now < goal_time
      sleep(@clock.bpm_tick_span)
      now = Time.monotonic
    end
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
    accented?(note_num) ? 0x7f_u8 : 0x50_u8
  end
end
