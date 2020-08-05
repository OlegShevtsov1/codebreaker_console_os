# frozen_string_literal: true

shared_context 'with game creation' do
  let(:player) { CodebreakerOs::Player.new('test') }
  let(:difficulty) { CodebreakerOs::Difficulty.new(DIFFICULTY_LEVELS[:easy]) }
  let(:game) { CodebreakerOs::Game.new(player, difficulty) }
end
