# notation:
#
# meter           duration(seconds) of a crotchet(one beat)
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
#
# melody_forrest_gump =
#   meter: 0.25
#   score: """
#     +
#     .345|5.3.|5..8|5.3.|.456|6.4.|6...|~
#     .456|6.4.|6.9.|7.5.|.345|5.8.|5...|~
#     .678|8.6.|8..6|8.6.|.456|6.4.|6...|~
#     .456|6.4.|2..3|4.2.|..1.|~|~
#   """
#
# melody_anonymous =
#   meter: 0.12
#   score: """
#     +
#     0833|8...|
#     ..33|8.2<32>|2#122|7...|
#     ..22|7.1<21>|1b111|6...|
#     ..11|6.=7<87>|7677|+#5...|
#     ..6.|7..#5|6...|..00|
#   """
#
# melody =
#   meter: 0.25
#   score: ""
#   tonality:
#     1: '#1'
#     4: '#4'
#     5: '#5'
#

# keyboard interaction

window.keyboard.add_press_action 'spacebar', ->
  stop_playing()
  start_playing()

window.keyboard.add_press_handler (key_event) ->
  stop_playing() unless \
    window.keyboard.is_auto_triggered(key_event) or 
    window.keyboard.key_equals(key_event, 'spacebar')


# auxiliary

generator = (container) ->
  current = 0
  next: ->
    container[current++]

delay = (callback, seconds) ->
  console.log 'calling in', seconds
  setTimeout callback, seconds * 1000

bind = (func, args...) ->
  -> func.apply @, args

# data

get_melody_from_input = ->
  meter: parseFloat $('#meter').val()
  score: $('#score').val()

# keyboard

holded_keys = []

hold_key = (key_literal) ->
  window.keyboard.simulate_keydown key_literal
  holded_keys += key_literal

release_holded_keys = ->
  window.keyboard.simulate_keyup k for k in holded_keys
  holded_keys = []

press_key = (key_literal) ->
  console.log 'down', key_literal
  window.keyboard.simulate_keydown key_literal

release_key = (key_literal) ->
  console.log 'up', key_literal
  window.keyboard.simulate_keyup key_literal

# play

notation_to_key_literal =
  '1': '1'
  '2': '2'
  '3': '3'
  '4': '4'
  '5': '5'
  '6': '6'
  '7': '7'
  'C': '8'
  'D': '9'
  'E': '0'
  'F': '-'
  'G': '='
  '#': 'A'
  'b': 'Z'

play = (melody) ->
  meter = melody.meter
  score_scanner = generator melody.score
  timeout_obj = null
  end_playing = ->
    clearTimeout timeout_obj
  # todo: implement a tape-recorder-buttons like relationship between the state switches
  # this is sooooooooooooo ugly

  octave_key_state = 
    '+': off
    '-': off

  octave_notation_to_key_literal =
    '+': 'S'
    '-': 'X'

  activate_octave_key = (type) ->
    unless octave_key_state[type] is on
      press_key octave_notation_to_key_literal[type]
      octave_key_state[type] = on

  deactivate_octave_key = (type) ->
    unless octave_key_state[type] is off
      release_key octave_notation_to_key_literal[type]
      octave_key_state[type] = off

  play_on_musiculator = (note_notation) ->
      hold_key notation_to_key_literal[note_notation]

  cookbook = 
    '.': -> 
      playon
    '~': do (beats_to_wait = 4) -> ->
      if --beats_to_wait is 0
        beats_to_wait = 4
        playon 
      else 
        arguments.callee
    '+': ->
      activate_octave_key '+'
      deactivate_octave_key '-'
      playon()
    '-': ->
      activate_octave_key '-'
      deactivate_octave_key '+'
      playon()
    '=': ->
      deactivate_octave_key '-'
      deactivate_octave_key '+'
      playon()

    # '0': ->
    #   release_holded_keys()
    #   playon
    # other note notations to add
    # '#': ->
    #   play_on_musiculator '#'
    #   playon()
    # '<': ->
    #   meter /= 2
    #   playon()
    # '(': ->
    #   release_holded_keys()
    #   notes = (n while (n = score_scanner.next()) != ')')
    #   play_on_musiculator n for n in notes
    #   playon

  add_play_action_to_cookbook = (notation) ->
    cookbook[notation] = ->
      release_holded_keys()
      play_on_musiculator notation
      playon

  add_play_action_to_cookbook notation for notation of notation_to_key_literal

  lookup_cookbook = (notation) ->
    if notation? then cookbook[notation] ? -> playon() else end_playing()
    # need to find a way to really end playing

  playon = ->
    do lookup_cookbook score_scanner.next()

  do beat_it_up = (action = playon) ->
    delay bind(beat_it_up, action()), meter

# api

playing = no

start_playing = ->
  return if playing
  playing = yes
  play get_melody_from_input()

stop_playing = ->
  return unless playing
  playing = no
  #release_holded_keys()
  #     if playing_timeout_obj?
  #       clearTimeout playing_timeout_obj

window.autoplay = {
  start_playing,
  stop_playing
}

# # play

# stop_playing = ->
#   if playing
#     playing = no
#     window.keyboard.simulate_keyup 'S'
#     release_holded_keys()
#     if playing_timeout_obj?
#       clearTimeout playing_timeout_obj

# play_note = (note_char) ->
#   switch note_char
#     when '.' then return
#     else
#       release_holded_keys()
#       hold_key note_char

# play_notes = (note_chars) ->
#   release_holded_keys()
#   for n in note_chars
#     hold_key n