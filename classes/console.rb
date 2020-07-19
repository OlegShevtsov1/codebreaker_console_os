# frozen_string_literal: true

class Console
  include Validating
  include View
  attr_accessor :user_code

  def initialize
    @user_code = []
  end

  def run
    message(:Welcome)
    main_menu
  end

  def main_menu
    message(:MainMenu)
    answer = user_enter
    return menu_result(answer) if MAIN_MENU_OPTIONS.include?(answer)

    message(:InvalidCommand)
    main_menu
  end

  private

  def start
    registration
    game_scenario
  end

  def game_scenario
    loop do
      return lost if game.lost?

      message(:Msg)
      process_answer_game(user_enter)
    end
  end

  def process_answer_game(answer)
    case answer
    when /^[1-6]{4}$/
      return won if game.won?(answer.split('').map(&:to_i))
    when 'hint' then request_of_hint
    else message(:InvalidCommand)
    end
  end

  def menu_result(answer)
    send(MAIN_MENU_OPTIONS[answer])
    main_menu if answer != START_COMMAND
  end

  def request_of_hint
    game.hints.zero? ? message(:HintsEnded) : (puts game.use_hint)
  end

  def check_code(answer)
    result = game.result(answer)

    puts template(result)
    result
  end

  def registration
    CodebreakerOs.run_game(input_name, input_difficulty)
  end

  def input_name
    message(:EnterName)
    answer = user_enter

    return answer if valid_name?(answer)

    message(:InvalidCommand)
    input_name
  end

  def input_difficulty
    message(:EnterDifficulty)
    answer = user_enter
    return answer if DIFFICULTIES.include?(answer.to_sym)

    message(:InvalidCommand)
    input_difficulty
  end

  def save_result?
    message(:SaveResult)
    user_enter == CONFIRM_COMMAND
  end

  def won
    message(:Won)
    game.save_result if save_result?
    main_menu
  end

  def lost
    message(:Loss)
    puts game.secret_code.join
    main_menu
  end

  def user_enter
    enter = gets.chomp.downcase
    if exit?(enter)
      message(:Exit)
      exit
    end
    enter
  end

  def exit?(answer)
    answer == EXIT_COMMAND
  end

  def game
    CurrentGame.game
  end
end
