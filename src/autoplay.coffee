#
# notation:
#
# meter
# duration(seconds) of a crotchet(one beat)
#
# .
# do nothing
#
# ~
# do nothing for a semibreve(four beats)
#
# 0
# deactivate keys
#
# 1234567CDEFGAB
# activate music keys, deactivate previous keys
#
# <
# pace up. effect persists.
#
# >
# pace down. effect persists.
#
# #
# pitch up
#
# b
# pitch down
#
# +
# switch to the high-pitch octave. effect persists.
#
# -
# switch to the low-pitch octave. effect persists.
#
# =
# switch to the mid-pitch octave. effect persists.
#
# ()
# bundle a set of music keys to activate within the same beat
#
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
# play_melody = (melody) ->
#   {meter, score} = melody
#   cookbook = {}
#   cookbook['.'] = ->
#     -> playon()
#   cookbook['~'] = do (beats_to_wait = 4) -> ->
#     playon() if beats_to_wait-- is 0
#     arguments.callee
#   cookbook['0'] = ->
#     release_holded_keys()
#     -> playon()
#   cookbook['1'] = ->
#     # play note
#     -> playon()
#   cookbook['<'] = ->
#     meter /= 2
#     playon()
#   cookbook['#'] = ->
#     #don't know how to do this..
#     playon()
#   cookbook['+'] = ->
#     #implement this after module refactor
#     playon()
#   cookbook['('] = ->
#     notes = (n while (n = scanner.next()) != ')')
#     #play notes
#     -> playon()
#
#   play_score = (scanner) ->
#     symbol = score_scanner.next()
#

meter = 0.25

# simulate keyboard event

simulate_keydown = (char) ->
  trigger 'keydown', char.charCodeAt(0)

simulate_keyup = (char) ->
  trigger 'keyup', char.charCodeAt(0)
  
trigger = (event_type, which) ->
  e = jQuery.Event event_type
  e.which = which
  e.is_autoplay = true
  $(document).trigger(e)

holded_keys = ''

hold_key = (char) ->
  simulate_keydown char
  holded_keys += char

release_holded_keys = ->
  for k in holded_keys
    simulate_keyup k
  holded_keys = ''

# play

playing = false
playing_timeout_obj = null

start_playing = ->
  unless playing
    playing = true
    meter = parseFloat $('#meter').val()
    simulate_keydown 'S'
    play generator $('#score').val()

stop_playing = ->
  if playing
    playing = false
    simulate_keyup 'S'
    release_holded_keys()
    if playing_timeout_obj?
      clearTimeout playing_timeout_obj

play = (music_box) ->
  return unless playing
  symbol = music_box.next()
  switch symbol
    when '|', '\n', ' ' then play music_box
    when undefined then stop_playing()
    when '{'
      play_notes (note while (note = music_box.next()) != '}')
      delay (-> play music_box), meter
    else 
      play_note symbol
      delay (-> play music_box), meter

play_note = (note_char) ->
  switch note_char
    when '.' then return
    else
      release_holded_keys()
      hold_key note_char

play_notes = (note_chars) ->
  release_holded_keys()
  for n in note_chars
    hold_key n

generator = (input_stream) ->
  current = 0
  next: ->
    input_stream[current++]

delay = (callback, seconds) ->
  playing_timeout_obj = setTimeout callback, seconds * 1000

window.autoplay = {
  start_playing,
  stop_playing
}