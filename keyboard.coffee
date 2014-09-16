press_handlers = {}
release_handlers = {}

$(document).keydown (event) ->
  unless event.is_autoplay
    window.autoplay.stop_playing()
  press_handlers[event.which]?()

$(document).keyup (event) ->
  release_handlers[event.which]?()
  
add_press_handler = (keycode, handler) ->
  press_handlers[keycode] = handler
  
add_release_handler = (keycode, handler) ->
  release_handlers[keycode] = handler

window.keyboard = {
  add_press_handler,
  add_release_handler
}