# frozen_string_literal: true

DIFFICULTIES = {
  easy: { attempts: 5, hints: 2 },
  medium: { attempts: 10, hints: 1 },
  hell: { attempts: 5, hints: 1 }
}.freeze

MAIN_MENU_OPTIONS = {
  'start' => :start,
  'rules' => :rules,
  'stats' => :stats,
  'exit' => :exit
}.freeze

START_COMMAND = 'start'

CONFIRM_COMMAND = 'yes'

EXIT_COMMAND = 'exit'

RESULT_PLUS = '+'
RESULT_MINUS = '-'
