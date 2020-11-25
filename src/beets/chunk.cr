require "./pattern"

class Chunk
  property pattern : Pattern
  property play_times : Int32

  def initialize(@pattern, @play_times)
  end
end
