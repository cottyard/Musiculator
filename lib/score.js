// Generated by CoffeeScript 1.8.0
(function() {
  var compile, compile_melody_to_autoplayer_instructions, current_melody_index, get_melody_from_ui, melody_anonymous, melody_forrest_gump, melody_list, melody_lotr, put_melody_to_ui, show_next_melody,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  melody_forrest_gump = {
    tempo: 240,
    score: "+\n.345|5.3.|5..C|5.3.|.456|6.4.|6...|~\n.456|6.4.|6.D.|7.5.|.345|5.C.|5...|~\n.67C|C.6.|C..6|C.6.|.456|6.4.|6...|~\n.456|6.4.|2..3|4.2.|..1.|~|~"
  };

  melody_anonymous = {
    tempo: 240,
    score: "+\n0C33|C...|\n..33|C.2<32>|2#122|7...|\n..22|7.1<21>|1b111|6...|\n..11|6.=7<C7>|7677|+#5...|\n..6.|7..#5|6...|..00|"
  };

  melody_lotr = {
    tempo: 200,
    score: "..12|3.5.|3.2.|1...|\n..35|6.C.|7.5.|3..<43>|2...|\n1..<11>|-b7..<b7b7>|=1...|\n...<45>|#5..<54>|b3..<45>|4...|b3.2.|\n+1..<11>|=b7..<b7b7>|+1...|\n...<45>|#5...|5.#5.|#6...|#5..#6...|C...|~|~"
  };

  get_melody_from_ui = function() {
    return {
      tempo: parseInt($('#tempo').val()),
      score: $('#score').val()
    };
  };

  put_melody_to_ui = function(melody) {
    $('#tempo').val(melody.tempo);
    return $('#score').val(melody.score);
  };

  compile_melody_to_autoplayer_instructions = function(melody) {
    var add_music_symbol_to_cookbook, add_signature_symbol_to_cookbook, beat, beat_control, beat_controlled, cookbook, ignored_symbols, result_instructions, sb, score, score_scanner, symbol, tempo, _i, _j, _len, _len1, _ref, _ref1;
    tempo = melody.tempo, score = melody.score;
    score_scanner = window.util.generator(score);
    result_instructions = '';
    beat = 60000 / tempo;
    beat_control = true;
    beat_controlled = function(instructions) {
      if (beat_control) {
        return "%" + instructions + "(" + beat + ")";
      } else {
        return instructions;
      }
    };
    cookbook = {
      '+': function() {
        return '^-&+';
      },
      '-': function() {
        return '^+&-';
      },
      '=': function() {
        return '^+^-';
      },
      '<': function() {
        beat /= 2;
        return '';
      },
      '>': function() {
        beat *= 2;
        return '';
      },
      '0': function() {
        return beat_controlled('');
      },
      '.': function() {
        return "(" + beat + ")";
      },
      '~': function() {
        return "(" + (beat * 4) + ")";
      },
      '(': function() {
        beat_control = false;
        return '%';
      },
      ')': function() {
        beat_control = true;
        return "(" + beat + ")";
      }
    };
    add_music_symbol_to_cookbook = function(symbol) {
      return cookbook[symbol] = function() {
        return beat_controlled("~" + symbol);
      };
    };
    add_signature_symbol_to_cookbook = function(symbol) {
      return cookbook[symbol] = function() {
        return beat_controlled("~" + symbol + "~" + (score_scanner.next()));
      };
    };
    _ref = '1234567CDEFG';
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sb = _ref[_i];
      add_music_symbol_to_cookbook(sb);
    }
    _ref1 = '#b';
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      sb = _ref1[_j];
      add_signature_symbol_to_cookbook(sb);
    }
    ignored_symbols = ['\n', ' ', '|'];
    while ((symbol = score_scanner.next())) {
      if (__indexOf.call(ignored_symbols, symbol) < 0) {
        result_instructions += cookbook[symbol]();
      }
    }
    return result_instructions;
  };

  melody_list = [melody_forrest_gump, melody_anonymous, melody_lotr];

  current_melody_index = -1;

  compile = function() {
    return compile_melody_to_autoplayer_instructions(get_melody_from_ui());
  };

  show_next_melody = function() {
    if (++current_melody_index >= melody_list.length) {
      current_melody_index = 0;
    }
    return put_melody_to_ui(melody_list[current_melody_index]);
  };

  window.score = {
    compile: compile,
    show_next_melody: show_next_melody
  };

}).call(this);
