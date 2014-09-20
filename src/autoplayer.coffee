# instruction set for musiculator autoplayer
# #b+-1234567CDEFG    button representations of musiculator
# (\d*)               milliseconds to wait
# ~                   hold next button
# &                   hold next button but don't keep a record
# ^                   unhold next button
# %                   unhold all holded buttons

# interaction

window.keyboard.add_press_handler (key_event) ->
  if window.keyboard.is_auto_triggered(key_event)
    return
  stop()

# keyboard

button_to_keyboard_literal =
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
  '+': 'S'
  '-': 'X'

press_button = (button) ->
  window.keyboard.simulate_keydown button_to_keyboard_literal[button]

release_button = (button) ->
  window.keyboard.simulate_keyup button_to_keyboard_literal[button]

# play

start_playing = (instructions, callback_on_termination) ->
  instr_scanner = window.util.generator instructions
  timeout_obj = null
  holded_buttons = []
  holded_buttons_not_recorded = []

  delay = (callback, millisecs) ->
    timeout_obj = setTimeout callback, millisecs

  hold_button = (button, holded_list = holded_buttons) ->
    press_button button
    holded_list.push button

  unhold_button = (button, holded_list = holded_buttons) ->
    release_button button
    unholded = holded_list.indexOf button
    holded_list.splice unholded, unholded

  unhold_all = (holded_list = holded_buttons) ->
    release_button k for k in holded_list
    holded_list= []

  cookbook =
    '~': ->
      hold_button instr_scanner.next()
      move_on()
    '^': ->
      unhold_button instr_scanner.next()
      move_on()
    '&': ->
      hold_button instr_scanner.next(), holded_buttons_not_recorded 
      move_on()
    '%': ->
      unhold_all()
      move_on()
    '(': ->
      digits = (n while (n = instr_scanner.next()) != ')')
      millisecs = parseInt digits.join ''
      delay move_on, millisecs

  # roll the ball

  do move_on = ->
    instr = instr_scanner.next()
    if instr?
      cookbook[instr]()
    else
      end_playing()
      callback_on_termination()

  end_playing = ->
    unhold_all holded_buttons
    unhold_all holded_buttons_not_recorded
    clearTimeout timeout_obj if timeout_obj?

  return end_playing

# api

playing = no
end_playing_func = null

play = (instructions) ->
  unless playing
    end_playing_func = start_playing instructions, -> playing = no
    playing = yes

stop = ->
  if playing
    end_playing_func()
    playing = no

window.autoplayer = {
  play,
  stop
}