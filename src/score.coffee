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
.345|5.3.|5..C|5.3.|.456|6.4.|6...|~
.456|6.4.|6.D.|7.5.|.345|5.C.|5...|~
.67C|C.6.|C..6|C.6.|.456|6.4.|6...|~
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

melody_lotr =
  tempo: 200
  score: """
..12|3.5.|3.2.|1...|
..35|6.C.|7.5.|3..<43>|2...|
1..<11>|-b7..<b7b7>|=1...|
...<45>|#5..<54>|b3..<45>|4...|b3.2.|
+1..<11>|=b7..<b7b7>|+1...|
...<45>|#5...|5.#5.|#6...|#5..#6...|C...|~|~
"""


# melody =
#   tempo: ?
#   score: ""
#   key_signatures: (to be supported)
#     1: '#1'
#     4: '#4'
#     5: '#5'

# interaction

get_melody_from_ui = ->
  tempo: parseInt $('#tempo').val()
  score: $('#score').val()

put_melody_to_ui = (melody) ->
  $('#tempo').val(melody.tempo)
  $('#score').val(melody.score)

# compilation

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
    ')': -> beat_control = on; "(#{beat})"
    
  add_music_symbol_to_cookbook = (symbol) ->
    cookbook[symbol] = -> beat_controlled "~#{symbol}"
    
  add_signature_symbol_to_cookbook = (symbol) ->
    cookbook[symbol] = -> 
      beat_controlled "~#{symbol}~#{score_scanner.next()}"

  add_music_symbol_to_cookbook sb for sb in '1234567CDEFG'
  add_signature_symbol_to_cookbook sb for sb in '#b'

  ignored_symbols = ['\n', ' ', '|']

  while (symbol = score_scanner.next())
    result_instructions += cookbook[symbol]() unless symbol in ignored_symbols

  return result_instructions

# api

melody_list = [melody_forrest_gump, melody_anonymous, melody_lotr]
current_melody_index = -1

compile = ->
  compile_melody_to_autoplayer_instructions get_melody_from_ui()

show_next_melody = ->
  if ++current_melody_index  >= melody_list.length
    current_melody_index = 0
  put_melody_to_ui(melody_list[current_melody_index ])

window.score = {
  compile,
  show_next_melody
}
