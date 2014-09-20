# data representation of a melody
# tempo           60 / duration(seconds) of a crotchet(one beat)

# score symbols for playing on the piano/musiculator:
# .               do nothing
# ~               do nothing for a semibreve(four beats)
# 0               deactivate keys
# 1234567CDEFG    activate music keys, deactivate previous keys
# <               pace up. effect persists.
# >               pace down. effect persists.
# #               pitch up
# b               pitch down
# +               switch to the high-pitch octave. effect persists.
# -               switch to the low-pitch octave. effect persists.
# =               switch to the mid-pitch octave. effect persists.
# ()              bundle a set of music keys to activate within the same beat
# to be supported
# [\d*:           start repetition
# :]              end repetition

# melody repositories

melody_forrest_gump =
  tempo: 240
  score: """
    +
    .345|5.3.|5..8|5.3.|.456|6.4.|6...|~
    .456|6.4.|6.9.|7.5.|.345|5.8.|5...|~
    .678|8.6.|8..6|8.6.|.456|6.4.|6...|~
    .456|6.4.|2..3|4.2.|..1.|~|~
  """

melody_anonymous =
  tempo: 240
  score: """
    +
    0C33|C...|
    ..33|C.2<32>|2#122|7...|
    ..22|7.1<21>|1b111|6...|
    ..11|6.=7<C7>|7677|+#5...|
    ..6.|7..#5|6...|..00|
  """



# melody =
#   tempo: ?
#   score: ""
#   key_signatures: (to be supported)
#     1: '#1'
#     4: '#4'
#     5: '#5'

get_melody_from_input = ->
  tempo: parseInt $('#tempo').val()
  score: $('#score').val()

compile_melody_to_autoplayer_instructions = (melody) ->
  {tempo, score} = melody
  score_scanner = window.util.generator score
  result_instructions = ''
  beat = 60000 / tempo

  beat_control = on
  beat_controlled = (instructions) ->
    if beat_control then "%#{instructions}(#{beat})" else instructions

  cookbook =
    '+': -> '^-&+'
    '-': -> '^+&-'
    '=': -> '^+^-'
    '<': -> beat /= 2; ''
    '>': -> beat *= 2; ''
    '0': -> beat_controlled ''
    '.': -> "(#{beat})"
    '~': -> "(#{beat * 4})"
    '(': -> beat_control = off; '%'
    ')': -> beat_control = on; '#{beat}'
    
  add_music_symbol_to_cookbook = (symbol) ->
    cookbook[symbol] = -> beat_controlled "~#{symbol}"
    
  add_signature_symbol_to_cookbook = (symbol) ->
    cookbook[symbol] = -> 
      beat_controlled "~#{symbol}~#{score_scanner.next()}"

  add_music_symbol_to_cookbook sb for sb in '1234567CDEFG'
  add_signature_symbol_to_cookbook sb for sb in '#b'

  ignored_symbols = ['\n', ' ', '|']

  until (symbol = score_scanner.next()) is undefined
    result_instructions += cookbook[symbol]() unless symbol in ignored_symbols

  return result_instructions
  
compile = ->
  compile_melody_to_autoplayer_instructions get_melody_from_input()

window.score = {
  compile
}
