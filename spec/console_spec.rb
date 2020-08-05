# frozen_string_literal: true

RSpec.describe CodebreakerConsole::Console do
  include_context 'with game creation'

  let(:console) { described_class.new('spec/fixtures/test_statistics.yml') }

  describe '#registration' do
    context 'when correct user enter' do
      let(:player_name) { 'test' }

      it 'return name' do
        allow(console).to receive(:user_enter).and_return(player_name)
        allow(console).to receive(:message).with(:'registration.enter_player_name')
        expect(player.name).to eq(player_name)
      end

      it 'return difficulty level' do
        console.instance_variable_set(:@difficulty, game.difficulty)
        allow(console).to receive(:select_difficulty_level).and_return(game.difficulty)
        expect(game.difficulty[:name]).to eq(:easy)
      end
    end

    context 'when incorrect user enter' do
      let(:min_length_and_correct_player_names) { %w[Fo test] }
      let(:max_length_and_correct_player_names) { ['a' * 21, 'test'] }
      let(:incorrect_correct_difficulty_names) { ['asdf', DIFFICULTY_LEVELS[:easy]] }

      it 'show error message when name.length < 4' do
        allow(console).to receive(:user_enter).and_return(*min_length_and_correct_player_names)
        allow(console).to receive(:message).with(:'registration.enter_player_name').twice
        expect(console).to receive(:message).with(:'errors.message.player').once
        console.send(:enter_name)
      end

      it 'show error message when name.length > 20' do
        allow(console).to receive(:user_enter).and_return(*max_length_and_correct_player_names)
        allow(console).to receive(:message).with(:'registration.enter_player_name').twice
        expect(console).to receive(:message).with(:'errors.message.player').once
        console.send(:enter_name)
      end

      it 'show error message when wrong difficulty selected' do
        allow(console).to receive(:user_enter).and_return(*incorrect_correct_difficulty_names)
        allow(console).to receive(:message).with(:'registration.select_difficulty').twice
        expect(console).to receive(:message).with(:'errors.message.difficulty').once
        console.send(:select_difficulty_level)
      end
    end
  end

  context 'when run console' do
    it 'call main menu' do
      expect(console).to receive(:main_menu)
      console.run
    end
  end

  describe '#request_of_hints' do
    let(:secret_number) { '1234' }

    context 'when call request of hint' do
      before do
        console.instance_variable_set(:@game, game)
        game.instance_variable_set(:@secret_number, secret_number)
        allow(console).to receive(:loop).and_yield
      end

      it 'give a hint if available' do
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        expect(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end

      it 'show error message for hints not available' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        expect(console).to receive(:message).with(:'errors.message.no_hints')
        allow(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end
    end
  end

  describe '#game_scenario' do
    let(:secret_number) { '1234' }

    before do
      allow(console).to receive(:loop).and_yield
      game.instance_variable_set(:@secret_number, secret_number)
      console.instance_variable_set(:@game, game)
      allow(console).to receive(:registration).and_return(game)
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.start_command'))
    end

    after do
      console.send(:start)
    end

    context 'when correct player guess entered' do
      let(:secret_number) { '1234' }
      let(:hint_value) { '1' }

      it 'show prompts to save result' do
        allow(console).to receive(:user_enter).and_return(secret_number)
        allow(console).to receive(:message).with(:'play.enter_guess')
        allow(console).to receive(:message).with(:'play.win')
        expect(console).to receive(:save_result?).and_return(I18n.t(:'play.yes'))
        allow(console).to receive(:main_menu)
      end

      it 'show win' do
        allow(console).to receive(:user_enter).and_return(secret_number)
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:message).with(:'play.win')
        allow(console).to receive(:save_result?).and_return(I18n.t(:'play.yes'))
        allow(console).to receive(:main_menu)
      end

      it 'show hint if available for player' do
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        allow(game).to receive(:hint).and_return(hint_value)
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:puts).with("#{I18n.t(:'play.hint')}: #{hint_value}")
      end

      it 'show message when no hints available' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(I18n.t(:'play.hint'))
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:message).with(:'errors.message.no_hints')
      end

      it 'lost game when all attempts used' do
        allow(game).to receive(:attempts_available?).and_return(false)
        allow(console).to receive(:message).with(:'play.lost')
        allow(console).to receive(:puts).with(game.secret_number)
        expect(console).to receive(:main_menu)
      end
    end

    context 'when incorrect command entered' do
      let(:player_name) { 'test' }

      it 'show corresponding message' do
        allow(game).to receive(:hints_available?).and_return(false)
        allow(console).to receive(:user_enter).and_return(player_name)
        allow(console).to receive(:message).with(:'play.enter_guess')
        expect(console).to receive(:message).with(:'errors.message.wrong_command')
      end
    end
  end

  after(example: :calls_exit) do
    console.send(:start)
  end

  context 'when correct user enter' do
    let(:player_name) { 'test' }

    before do
      allow(console).to receive(:message).with(:'registration.enter_command')
      allow(console).to receive(:enter_name).and_return(player_name)
      allow(console).to receive(:select_difficulty_level) { DIFFICULTY_LEVELS[:easy] }
    end

    it 'call method start' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.start_command'))
      allow(console).to receive(:message).and_return(:welcome)
      allow(console).to receive(:loop).and_yield
      expect(console).to receive(:start)
      console.run
    end
  end

  context 'when correct method calling' do
    let(:secret_number) { '1234' }
    let(:incorrect_correct_start_commands) { ['star', I18n.t(:'play.exit_command')] }

    before(:example, :start) do
      console.instance_variable_set(:@player, game.player)
      allow(console).to receive(:enter_name).and_return(game.player)
      console.instance_variable_set(:@difficulty, difficulty)
      allow(console).to receive(:select_difficulty_level) { difficulty }
    end

    it 'call method start', :start do
      allow(console).to receive(:loop).and_yield
      allow(console).to receive(:user_enter).and_return(secret_number)
      allow(console).to receive(:message).with(:'play.enter_guess')
      expect(console).to receive(:start).and_call_original
      console.send(:start)
    end

    it 'call method rules' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.rules_command'))
      allow(console).to receive(:rules).and_call_original
      expect { console.rules }.to output(/Codebreaker is a logic game/).to_stdout
    end

    it 'call method stats' do
      allow(console).to receive(:user_enter).and_return(I18n.t(:'play.stats_command'))
      expect(console).to receive(:stats).and_call_original
      console.stats
    end

    it 'call method exit', :calls_exit do
      allow(console).to receive(:gets).and_return(I18n.t(:'play.exit_command'))
      expect(console).to receive(:message).with(:goodbye)
      allow(console).to receive(:exit)
      console.user_enter
    end

    it 'checks main menu command', :calls_exit do
      allow(console).to receive(:user_enter).and_return(*incorrect_correct_start_commands)
      allow(console).to receive(:message).with(:'registration.enter_command').twice
      expect(console).to receive(:message).with(:'errors.message.unexpected_command').once
      allow(console).to receive(:message).and_return(I18n.t(:welcome))
      console.run
    end
  end
end
