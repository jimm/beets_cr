class DrumKit
  property instruments : Hash(String, UInt8) = {} of String => UInt8

  def add_instrument(name, note)
    instruments[name] = note
  end

  def instrument_note_number(name)
    name = name.downcase
    GM_DRUM_NOTE_NAMES.each_with_index do |gm_name, i|
      return (i + GM_DRUM_NOTE_LOWEST).to_u8 if "#{gm_name}".downcase == name
    end
    instruments.keys.each do |inst_name|
      return instruments[inst_name] if inst_name.downcase == name
    end
    raise "can not find instrument named #{name}"
  end
end
