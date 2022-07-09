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

  def self.accented(note_num)
    note_num | 0x80
  end

  def self.unaccented(note_num)
    note_num & 0x7f
  end

  def self.accented?(note_num)
    (note_num & 0x80) != 0
  end

  def self.velocity(note_num)
    accented?(note_num) ? 0x7f_u8 : 0x50_u8
  end

  def initialize(@name, @num_bars)
    @notes = Array.new(ticks_length) { |a| a = [] of UInt8 }
  end

  # FIXME hard-coded number of beats per bar
  def ticks_length
    @num_bars * 4 * TICKS_PER_BEAT
  end
end
