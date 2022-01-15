require "./midi_consts"

class Clock
  NANOSECS_PER_SEC = 1_000_000_000

  property bpm : Float64 = 120.0
  property running = false

  def initialize(@output_stream : OutputStream)
    @prev_bpm = 0.0
    @tick_span = Time::Span.new(nanoseconds: 0_i64)
  end

  def start
    @running = true
    spawn do
      t = Time.monotonic
      while @running
        t += bpm_tick_span()
        wait_until(t)
        @output_stream.write_short(CLOCK)
      end
    end
  end

  def stop
    @running = false
  end

  def wait_until(goal_time : Time::Span)
    now = Time.monotonic
    while now < goal_time
      sleep(bpm_tick_span())
      now = Time.monotonic
    end
  end

  def bpm_tick_span
    if @prev_bpm != @bpm
      @tick_span = Time::Span.new(nanoseconds: (NANOSECS_PER_SEC / (@bpm * TICKS_PER_BEAT / 60.0)).to_i64)
      @prev_bpm = @bpm
    end
    @tick_span
  end
end
