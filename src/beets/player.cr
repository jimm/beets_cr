require "./chunk"
require "./pattern"
require "./drum_kit"
require "./clock"
require "./midi_consts"

NOTE_OFF_SPAN = Time::Span.new(nanoseconds: 3_000_000)

class Player
  property song_name : String?
  property channel : UInt8 = 9_u8
  property bank_msb : UInt8?
  property bank_lsb : UInt8?
  property program : UInt8??
  property transpose : Int32 = 0
  property output_clock : Bool = false
  property drum_kit : DrumKit = DrumKit.new
  property patterns : Array(Pattern) = [] of Pattern
  property chunks : Array(Chunk) = [] of Chunk
  property clock

  def initialize(@output_stream : OutputStream)
    @clock = Clock.new(@output_stream)
  end

  def play
    puts("play: @transpose = #{@transpose}") # DEBUG
    on_status = NOTE_ON + channel
    off_status = NOTE_OFF + channel
    nowait = clock.half_tick_span >= NOTE_OFF_SPAN

    @clock.start if @output_clock
    chunks.each do |chunk|
      pattern = chunk.pattern
      chunk.play_times.times do |_|
        start_nanosecs = Time.monotonic

        t = start_nanosecs
        pattern.notes.each do |notes|
          if notes.empty?
            t += @clock.bpm_tick_span
            next
          end

          @clock.wait_until(t)
          notes.each do |note|
            @output_stream.write_short(
              on_status, Pattern.unaccented(note + @transpose), Pattern.velocity(note + @transpose)
            )
          end
          @clock.wait_until(t + NOTE_OFF_SPAN) unless nowait
          notes.each do |note|
            @output_stream.write_short(
              off_status, Pattern.unaccented(note + @transpose), 0
            )
          end

          t += @clock.bpm_tick_span
        end

        # Wait for end of full length of pattern
        @clock.wait_until(start_nanosecs + @clock.bpm_tick_span * pattern.ticks_length)
      end
    end
    @clock.stop if @output_clock
  end
end
