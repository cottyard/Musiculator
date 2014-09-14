meter = 0.25
play_list = """
.345|5.3.|5..8|5.3.|.456|6.4.|6...|....
.456|6.4.|6.9.|7.5.|.345|5.8.|5...|....
.678|8.6.|8..6|8.6.|.456|6.4.|6...|....
.456|6.4.|2..3|4.2.|..1.|....|....
"""

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
    simulate_keydown 'S'
    play generator play_list

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
    when '|', '\n' then play music_box
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