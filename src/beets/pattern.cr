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
