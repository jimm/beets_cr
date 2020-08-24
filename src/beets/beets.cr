require "option_parser"
require "port_midi"
require "./player"

# Command line options.
class Options
  property list_devices : Bool = false
  property beets_path : String = ""
  property debug : Bool = false
end

# TODO: Write documentation for `Beets`
class Beets
  VERSION = "0.1.0"

  def main
    options = parse_command_line_args
    begin
      PortMIDI.init
      if options.list_devices
        PortMIDI.list_all_devices
      else
        run(options.beets_path)
      end
      PortMIDI.terminate
    rescue ex
      STDERR.puts ex.message
      if options.debug
        puts ex.backtrace.join("\n")
      end
      exit(1)
    end
  end

  def run(path)
    if !File.exists?(path)
      raise "error: file #{path} does not exist"
    end
    player = Player.from_file(path)
    player.play
  end

  # Parses command line arguments and returns an `Options` instance.
  def parse_command_line_args
    options = Options.new
    parser = OptionParser.parse do |parser|
      parser.banner = "usage: beets [arguments] [file]"
      parser.on("-l", "--list-devices", "List MIDI devices") { options.list_devices = true }
      parser.on("-d", "--debug", "Debug output") { options.debug = true }
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

    if !options.list_devices
      if ARGV.empty?
        STDERR.puts "error: must specify a beets file"
        exit(1)
      end
      options.beets_path = ARGV[0]
    end
    options
  end

  def help(parser, f = STDOUT)
    f.puts parser
  end
end
