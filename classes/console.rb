# frozen_string_literal: true

module CodebreakerConsole
  class Console
    STORAGE_FILE = 'statistics.yml'

    attr_reader :game, :storage_wrapper

    include Output

    def initialize(storage_file = STORAGE_FILE)
      @storage_wrapper = CodebreakerOs::StorageWrapper.new(storage_file)
    end

    def run
      message(:welcome)
      main_menu
    end

    private

    def main_menu
      message(:mainmenu)
      answer = user_enter
      return process_answer_menu(answer) if MAIN_MENU_COMMANDS.key?(answer.to_sym)

      message(:'errors.message.unexpected_command')
      main_menu
    end

    def start
      registration
      game_scenario
    end

    def game_scenario
      loop do
        return lost unless game.attempts_available?

        message(:'play.enter_guess')
        process_answer_game(user_enter)
      end
    end

    def process_answer_game(answer)
      guess = CodebreakerOs::Guess.new(answer)
      if guess.valid?
        puts compare(guess.value)
      elsif guess.value == I18n.t(:'play.hint')
        request_of_hint
      else
        message(:'errors.message.wrong_command')
      end
    end

    def process_answer_menu(answer)
      send(MAIN_MENU_COMMANDS[answer.to_sym])
      main_menu if answer != I18n.t(:'play.start_command')
    end

    def request_of_hint
      return message(:'errors.message.no_hints') unless game.hints_available?

      puts "#{I18n.t(:'play.hint')}: #{game.hint}"
    end

    def compare(answer)
      return won if game.win?(answer)

      CodebreakerOs::Guess.decorate(game.compare(answer))
    end

    def registration
      enter_name
      describe_difficulty_levels
      select_difficulty_level
      @game = CodebreakerOs::Game.new(@player, @difficulty)
    end
  end
end
