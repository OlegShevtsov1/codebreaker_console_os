# frozen_string_literal: true

module CodebreakerConsole
  module Output
    MAIN_MENU_COMMANDS = { start: :start, rules: :rules, stats: :stats, exit: :exit }.freeze

    def user_enter
      enter = gets.chomp.downcase
      if exit?(enter)
        message(:goodbye)
        exit
      end
      enter
    end

    def enter_name
      message(:'registration.enter_player_name')
      @player = CodebreakerOs::Player.new(user_enter)
      return @player if @player.valid?

      message(:'errors.message.player')
      enter_name
    end

    def rules
      message(:rules)
    end

    def select_difficulty_level
      message(:'registration.select_difficulty')
      @difficulty = CodebreakerOs::Difficulty.new(user_enter.to_sym)
      return @difficulty if @difficulty.valid?

      message(:'errors.message.difficulty')
      select_difficulty_level
    end

    def save_result?
      message(:'play.save_results')
      user_enter == I18n.t(:'play.yes_command')
    end

    def won
      message(:'play.win')
      if save_result?
        @yml_store = @storage_wrapper.new_store
        save_storage unless @storage_wrapper.storage_exists?
        synchronize_storage
        @winners << game
        save_storage
      end
      main_menu
    end

    def lost
      message(:'play.lost')
      puts game.secret_number
      main_menu
    end

    def exit?(answer)
      answer == I18n.t(:'play.exit_command')
    end

    def save_storage
      @yml_store.transaction { @yml_store[:winners] = @winners || [] }
    end

    def synchronize_storage
      @yml_store.transaction(true) { @winners = @yml_store[:winners] }
    end

    def stats
      winners = YAML.load_file(storage_wrapper.storage_file)[:winners]
      sorted_winners = CodebreakerOs::Statistic.sorted_winners(winners)
      tp CodebreakerOs::Statistic.decorated_top_players(sorted_winners)
    end

    def message(type)
      puts I18n.t(type)
    end

    def describe_difficulty_levels
      CodebreakerOs::Difficulty::LEVELS.each_key do |name|
        difficulty = CodebreakerOs::Difficulty::LEVELS[name]
        args = { name: difficulty[:name], attempts: difficulty[:attempts], hints: difficulty[:hints] }
        puts I18n.t(:'registration.difficulty_description', **args)
      end
    end
  end
end
