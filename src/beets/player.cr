require "port_midi"

class Player
  property channel : UInt8 = 9_u8
  property bank : UInt8?
  property pc : UInt8??
  property bpm : Float64 = 120.0
  property output_clock : Bool = false
  property patterns : Array(Int32) = [] of Int32

  # Parses `path` and returns a Player.
  def self.from_file(path)
    lines = File.read_lines(path)

    device_line = lines.grep(/^ *device: */).first.trim
    device_line =~ /device: (.*)/
    device_id = $1.to_i
    player = Player.new(OutputStream.open(device_id))

    lines.map(&.trim).each do |line|
      case line.trim
      when /channel: *(.*)/
        player.channel = ($1.to_i - 1).to_u8
      when /bank: *(.*)/
        player.bank = $1.to_u8
      when /program: *(.*)/
        player.program = $1.to_u8
      when /bpm: *(.*)/
        player.bpm = $1.to_f64
      when /clock: *(.*)/
        val = $1.downcase
        player.output_clock = ["on", "true", "yes"].includes?(val)
      end
    end
    player
    # TODO set all other values
  end

  def initialize(@output_stream : OutputStream)
  end

  def play
  end
end
