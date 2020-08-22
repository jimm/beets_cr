# MIDI constants.

MIDI_CHANNELS     =  16 # Number of MIDI channels
NOTES_PER_CHANNEL = 128 # Number of note per MIDI channel

# Channel messages

NOTE_OFF         = 0x80_u8 # Note, val
NOTE_ON          = 0x90_u8 # Note, val
POLY_PRESSURE    = 0xA0_u8 # Note, val
CONTROLLER       = 0xB0_u8 # Controller #, val
PROGRAM_CHANGE   = 0xC0_u8 # Program number
CHANNEL_PRESSURE = 0xD0_u8 # Channel pressure
PITCH_BEND       = 0xE0_u8 # LSB, MSB

# System common messages

SYSEX        = 0xF0_u8 # System exclusive start
SONG_POINTER = 0xF2_u8 # Beats from top: LSB/MSB 6 ticks 1 beat
SONG_SELECT  = 0xF3_u8 # Val number of song
TUNE_REQUEST = 0xF6_u8 # Tune request
EOX          = 0xF7_u8 # End of system exclusive

# System realtime messages
CLOCK        = 0xF8_u8 # MIDI clock (24 per quarter note)
START        = 0xFA_u8 # Sequence start
CONTINUE     = 0xFB_u8 # Sequence continue
STOP         = 0xFC_u8 # Sequence stop
ACTIVE_SENSE = 0xFE_u8 # Active sensing (sent every 300 ms when nothing else being sent)
SYSTEM_RESET = 0xFF_u8 # System reset

# Standard MIDI File meta event defs.
META_EVENT            = 0xff_u8
META_SEQ_NUM          = 0x00_u8
META_TEXT             = 0x01_u8
META_COPYRIGHT        = 0x02_u8
META_SEQ_NAME         = 0x03_u8
META_INSTRUMENT       = 0x04_u8
META_LYRIC            = 0x05_u8
META_MARKER           = 0x06_u8
META_CUE              = 0x07_u8
META_MIDI_CHAN_PREFIX = 0x20_u8
META_TRACK_END        = 0x2f_u8
META_SET_TEMPO        = 0x51_u8
META_SMPTE            = 0x54_u8
META_TIME_SIG         = 0x58_u8
META_PATCH_SIG        = 0x59_u8
META_SEQ_SPECIF       = 0x7f_u8

# Controller numbers
#    0 - 31 = continuous_u8, MSB
#   32 - 63 = continuous_u8, LSB
#   64 - 97 = momentary_u8 switches
CC_BANK_SELECT_MSB           = 0_u8
CC_BANK_SELECT               = CC_BANK_SELECT_MSB
CC_MOD_WHEEL_MSB             = 1_u8
CC_MOD_WHEEL                 = CC_MOD_WHEEL_MSB
CC_BREATH_CONTROLLER_MSB     = 2_u8
CC_BREATH_CONTROLLER         = CC_BREATH_CONTROLLER_MSB
CC_FOOT_CONTROLLER_MSB       = 4_u8
CC_FOOT_CONTROLLER           = CC_FOOT_CONTROLLER_MSB
CC_PORTAMENTO_TIME_MSB       = 5_u8
CC_PORTAMENTO_TIME           = CC_PORTAMENTO_TIME_MSB
CC_DATA_ENTRY_MSB            = 6_u8
CC_DATA_ENTRY                = CC_DATA_ENTRY_MSB
CC_VOLUME_MSB                = 7_u8
CC_VOLUME                    = CC_VOLUME_MSB
CC_BALANCE_MSB               = 8_u8
CC_BALANCE                   = CC_BALANCE_MSB
CC_PAN_MSB                   = 10_u8
CC_PAN                       = CC_PAN_MSB
CC_EXPRESSION_CONTROLLER_MSB = 11_u8
CC_EXPRESSION_CONTROLLER     = CC_EXPRESSION_CONTROLLER_MSB
CC_GEN_PURPOSE_1_MSB         = 16_u8
CC_GEN_PURPOSE_1             = CC_GEN_PURPOSE_1_MSB
CC_GEN_PURPOSE_2_MSB         = 17_u8
CC_GEN_PURPOSE_2             = CC_GEN_PURPOSE_2_MSB
CC_GEN_PURPOSE_3_MSB         = 18_u8
CC_GEN_PURPOSE_3             = CC_GEN_PURPOSE_3_MSB
CC_GEN_PURPOSE_4_MSB         = 19_u8
CC_GEN_PURPOSE_4             = CC_GEN_PURPOSE_4_MSB

# [32 - 63] are LSB for [0 - 31]
CC_BANK_SELECT_LSB           = (CC_BANK_SELECT_MSB + 32_u8)
CC_MOD_WHEEL_LSB             = (CC_MOD_WHEEL_MSB + 32_u8)
CC_BREATH_CONTROLLER_LSB     = (CC_BREATH_CONTROLLER_MSB + 32_u8)
CC_FOOT_CONTROLLER_LSB       = (CC_FOOT_CONTROLLER_MSB + 32_u8)
CC_PORTAMENTO_TIME_LSB       = (CC_PORTAMENTO_TIME_MSB + 32_u8)
CC_DATA_ENTRY_LSB            = (CC_DATA_ENTRY_MSB + 32_u8)
CC_VOLUME_LSB                = (CC_VOLUME_MSB + 32_u8)
CC_BALANCE_LSB               = (CC_BALANCE_MSB + 32_u8)
CC_PAN_LSB                   = (CC_PAN_MSB + 32_u8)
CC_EXPRESSION_CONTROLLER_LSB = (CC_EXPRESSION_CONTROLLER_MSB + 32_u8)
CC_GEN_PURPOSE_1_LSB         = (CC_GEN_PURPOSE_1_MSB + 32_u8)
CC_GEN_PURPOSE_2_LSB         = (CC_GEN_PURPOSE_2_MSB + 32_u8)
CC_GEN_PURPOSE_3_LSB         = (CC_GEN_PURPOSE_3_MSB + 32_u8)
CC_GEN_PURPOSE_4_LSB         = (CC_GEN_PURPOSE_4_MSB + 32_u8)

# Momentary MSB switches
CC_SUSTAIN           =  64_u8
CC_PORTAMENTO        =  65_u8
CC_SUSTENUTO         =  66_u8
CC_SOFT_PEDAL        =  67_u8
CC_HOLD_2            =  69_u8
CC_GEN_PURPOSE_5     =  50_u8
CC_GEN_PURPOSE_6     =  51_u8
CC_GEN_PURPOSE_7     =  52_u8
CC_GEN_PURPOSE_8     =  53_u8
CC_EXT_EFFECTS_DEPTH =  91_u8
CC_TREMELO_DEPTH     =  92_u8
CC_CHORUS_DEPTH      =  93_u8
CC_DETUNE_DEPTH      =  94_u8
CC_PHASER_DEPTH      =  95_u8
CC_DATA_INCREMENT    =  96_u8
CC_DATA_DECREMENT    =  97_u8
CC_NREG_PARAM_LSB    =  98_u8
CC_NREG_PARAM_MSB    =  99_u8
CC_REG_PARAM_LSB     = 100_u8
CC_REG_PARAM_MSB     = 101_u8

# Channel mode message values
# Val 0 == off, 0x7f == on
CM_RESET_ALL_CONTROLLERS = 0x79_u8
CM_LOCAL_CONTROL         = 0x7A_u8
CM_ALL_NOTES_OFF         = 0x7B_u8 # Val must be 0
CM_OMNI_MODE_OFF         = 0x7C_u8 # Val must be 0
CM_OMNI_MODE_ON          = 0x7D_u8 # Val must be 0
CM_MONO_MODE_ON          = 0x7E_u8 # Val = # chans_u8
CM_POLY_MODE_ON          = 0x7F_u8 # Val must be 0
