# frozen_string_literal: true

RSpec.describe Console do
  let(:console) { described_class.new }

  before do
    CodebreakerOs.run_game('test', 'easy')
  end

  let(:game) { CurrentGame.game }

  describe '#run' do
    context 'when run console' do
      it 'shows welcome message' do
        expect(console).to receive(:main_menu)
        console.run
      end
    end
  end

  describe '#main_menu' do
    context 'when correct user enter' do
      it 'calls method start' do
        expect(console).to receive(:message).with(:MainMenu)
        allow(console).to receive(:input_name).and_return('test')
        allow(console).to receive(:input_difficulty) { DIFFICULTIES[:easy] }
        allow(console).to receive(:user_enter).and_return('start')
        allow(console).to receive(:loop).and_yield
        expect(console).to receive(:start)
        console.main_menu
      end
    end
  end

  describe '#main_menu' do
    context 'when correct method calling' do
      it 'calls method start' do
        allow(console).to receive(:input_name).and_return('test')
        allow(console).to receive(:input_difficulty) { 'easy' }
        allow(console).to receive(:loop).and_yield
        allow(console).to receive(:user_enter).and_return('1234')
        expect(console).to receive(:message).with(:Msg)
        expect(console).to receive(:start).and_call_original
        console.send(:start)
      end

      it 'calls method rules' do
        allow(console).to receive(:user_enter).and_return('rules')
        expect(console).to receive(:message).with(:Rules)
        expect(console).to receive(:rules).and_call_original
        console.rules
      end

      it 'calls method stats' do
        allow(console).to receive(:user_enter).and_return('stats')
        expect(console).to receive(:stats).and_call_original
        console.stats
      end

      it 'calls method exit' do
        allow(console).to receive(:gets).and_return('exit')
        expect(console).to receive(:message).with(:Exit)
        expect(console).to receive(:exit)
        console.send(:user_enter)
      end
    end
  end

  describe '#request_of_hints' do
    context 'when call request of hint' do
      before do
        console.instance_variable_set(:@game, game)
        game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
        allow(console).to receive(:loop).and_yield
      end

      it 'gives a hint if they are not ended' do
        allow(console).to receive(:user_enter).and_return('hint')
        expect(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end

      it 'shows ended msg if hint are ended' do
        game.instance_variable_set(:@hints, 0)
        allow(console).to receive(:user_enter).and_return('hint')
        expect(console).to receive(:message).with(:HintsEnded)
        expect(console).to receive(:request_of_hint).and_call_original
        console.send(:request_of_hint)
      end
    end
  end

  describe '#registration' do
    context 'when correct user enter' do
      it 'returns name' do
        allow(console).to receive(:user_enter).and_return('test')
        expect(console).to receive(:message).with(:EnterName)
        expect(console.send(:input_name)).to eq('test')
      end

      it 'returns difficult hash' do
        allow(console).to receive(:user_enter).and_return('easy')
        expect(console).to receive(:message).with(:EnterDifficulty)
        expect(console.send(:input_difficulty)).to eq('easy')
      end
    end

    context 'when incorrect user enter' do
      it 'shows message Invalid enter when name.length < 4' do
        allow(console).to receive(:user_enter).and_return('asd', 'test')
        expect(console).to receive(:message).with(:EnterName).twice
        expect(console).to receive(:message).with(:InvalidCommand).once
        console.send(:input_name)
      end

      it 'shows message Invalid enter when name.length > 20' do
        allow(console).to receive(:user_enter).and_return('a' * 21, 'test')
        expect(console).to receive(:message).with(:EnterName).twice
        expect(console).to receive(:message).with(:InvalidCommand).once
        console.send(:input_name)
      end

      it 'shows message Invalid enter' do
        allow(console).to receive(:user_enter).and_return('asdf', 'easy')
        expect(console).to receive(:message).with(:EnterDifficulty).twice
        expect(console).to receive(:message).with(:InvalidCommand).once
        console.send(:input_difficulty)
      end
    end
  end

  describe '#game_scenario' do
    before do
      allow(console).to receive(:loop).and_yield
      game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
      console.instance_variable_set(:@game, game)
      allow(console).to receive(:registration).and_return(game)
      allow(console).to receive(:user_enter).and_return('start')
    end

    after do
      console.send(:start)
    end

    context 'when correct user enter' do
      it 'won when user_code and secret_code to equal' do
        allow(console).to receive(:user_enter).and_return('1234')
        expect(console).to receive(:message).with(:Msg)
        expect(console).to receive(:message).with(:Won)
        expect(console).to receive(:message).with(:SaveResult)
        expect(console).to receive(:main_menu)
      end

      it 'gives hint when hint not over' do
        allow(console).to receive(:user_enter).and_return('hint')
        allow(game).to receive(:use_hint).and_return(1)
        expect(console).to receive(:message).with(:Msg)
        expect(console).to receive(:puts).with(1)
      end

      it 'shows message "ended og hints" hint when hints is over' do
        game.instance_variable_set(:@hints, 0)
        allow(console).to receive(:user_enter).and_return('hint')
        expect(console).to receive(:message).with(:Msg)
        expect(console).to receive(:message).with(:HintsEnded)
      end

      it 'lost when attempts ended' do
        game.instance_variable_set(:@attempts, 0)
        expect(console).to receive(:message).with(:Loss)
        expect(console).to receive(:puts).with(game.secret_code.join)
        expect(console).to receive(:main_menu)
      end
    end

    context 'when incorrect user enter' do
      it 'shows message "invalid enter"' do
        game.instance_variable_set(:@hints, 0)
        allow(console).to receive(:user_enter).and_return('test')
        expect(console).to receive(:message).with(:Msg)
        expect(console).to receive(:message).with(:InvalidCommand)
      end
    end
  end
end
