# name the keys, shar flat, do re mi fa so la si h_do h_re h_mi h_fa h_so, h_oct, l_oct

press_actions = {}
release_actions = {}

add_press_action = (key_literal, action) ->
  press_actions[get_keycode key_literal] = action
  
add_release_action = (key_literal, action) ->
  release_actions[get_keycode key_literal] = action

add_press_handler = (handler) ->
  $(document).keydown handler

add_release_handler = (handler) ->
  $(document).keyup handler
  
$(document).keydown (event) ->
  press_actions[event.which]?()

$(document).keyup (event) ->
  release_actions[event.which]?()
  
keycode_map =
  '1': 49
  '2': 50
  '3': 51
  '4': 52
  '5': 53
  '6': 54
  '7': 55
  '8': 56
  '9': 57
  '0': 48
  '-': 189
  '=': 187
  'A': 65
  'Z': 90
  'S': 83
  'X': 88
  'spacebar': 32
  'NUM_1': 97
  'NUM_2': 98
  'NUM_3': 99
  'NUM_4': 100
  'NUM_5': 101
  'NUM_6': 102
  'NUM_7': 103
  'NUM_8': 104
  'NUM_9': 105
  'NUM_0': 96
  'NUM_.': 110
  'NUM_return': 13
  'NUM_+': 107
  'NUM_-': 109
  'NUM_*': 106
  'NUM_/': 111

get_keycode = (key_literal) ->
  keycode_map[key_literal]

is_auto_triggered = (key_event) ->
  key_event.is_auto_triggered

key_equals = (key_event, key_literal) ->
  key_event.which is get_keycode(key_literal)

simulate_keydown = (key_literal) ->
  trigger 'keydown', get_keycode key_literal

simulate_keyup = (key_literal) ->
  trigger 'keyup', get_keycode key_literal

trigger = (event_type, which) ->
  e = jQuery.Event event_type
  e.which = which
  e.is_auto_triggered = yes
  $(document).trigger(e)

window.keyboard = {
  add_press_action,
  add_release_action,
  simulate_keydown,
  simulate_keyup,
  get_keycode,
  key_equals,
  is_auto_triggered,
  add_press_handler,
  add_release_handler
}