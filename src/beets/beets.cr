require "option_parser"
require "port_midi"
require "./player"
require "./loader"

# Command line options.
class Options
  property list_devices : Bool = false
  property device_name_or_id : String?
  property channel : UInt8?
  property bpm : Float64?
  property transpose : Int32 = 0
  property beets_path : String = ""
  property debug : Bool = false
end

# TODO: Write documentation for `Beets`
class Beets
  VERSION = "0.1.0"

  getter options = Options.new

  def main
    parse_command_line_args
    begin
      PortMIDI.init
      if @options.list_devices
        PortMIDI.list_all_devices
      else
        run()
      end
    rescue ex
      STDERR.puts ex.message
      if options.debug
        puts ex.backtrace.join("\n")
      end
      exit(1)
    ensure
      PortMIDI.terminate
    end
  end

  def run
    if !File.exists?(@options.beets_path)
      raise "error: file #{@options.beets_path} does not exist"
    end
    player = Loader.new.load(@options.beets_path, @options.device_name_or_id,
      @options.channel, @options.bpm, @options.transpose)
    player.play
  end

  # Parses command line arguments and returns an `Options` instance.
  def parse_command_line_args
    parser = OptionParser.parse do |parser|
      parser.banner = "usage: beets [arguments] [file]"
      parser.on("-l", "--list-devices",
        "List MIDI devices") { @options.list_devices = true }
      parser.on("-o OUTPUT", "--output=OUTPUT",
        "Output MIDI device name or id") { |arg|
        @options.device_name_or_id = arg
      }
      parser.on("-c CHANNEL", "--channel=CHANNEL",
        "Output MIDI channel") { |arg|
        @options.channel = arg.to_u8 - 1
      }
      parser.on("-b BPM", "--bpm=BPM",
        "Beats per minute") { |arg| @options.bpm = arg.to_f64 }
      parser.on("-t TRANSPOSE", "--transpose=TRANSPOSE",
        "Transpose by (half steps)") { |arg| @options.transpose = arg.to_i }
      parser.on("-d", "--debug", "Debug output") { @options.debug = true }
      parser.on("-h", "--help", "Show this help") do
        help(parser)
        exit(0)
      end
      parser.invalid_option do |flag|
        STDERR.puts "error: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
      parser
    end

    if !@options.list_devices
      if ARGV.empty?
        STDERR.puts "error: must specify a beets file"
        exit(1)
      end
      @options.beets_path = ARGV[0]
    end
  end

  def help(parser, f = STDOUT)
    f.puts parser
  end
end
