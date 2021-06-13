require_relative '../spec_helper'

describe MiniPGM::BayesianNetwork do
  let(:model1) do
    MiniPGM::BayesianNetwork.new(
      MiniPGM::Edge.new('Difficulty', 'Grade'),
      MiniPGM::Edge.new('Intelligence', 'Grade'),
      MiniPGM::Edge.new('Intelligence', 'SAT'),
      MiniPGM::Edge.new('Grade', 'Letter'),
    )
  end

  describe '.reachable_from' do
    context 'Difficulty' do
      it 'returns the correct list of labels when nothing is observed' do
        reachable = model1.reachable_from('Difficulty', [])
        # Intelligence and SAT are blocked by a v-structure
        expect(reachable).to eq ['Difficulty', 'Grade', 'Letter']
      end

      it 'returns the correct list of labels when Grade is observed' do
        reachable = model1.reachable_from('Difficulty', ['Grade'])
        # Intelligence and SAT are now reachable, because v-structure was activated by Grade
        expect(reachable).to eq ['Difficulty', 'Intelligence', 'SAT']
      end

      it 'returns the correct list of labels when Letter is observed' do
        reachable = model1.reachable_from('Difficulty', ['Letter'])
        # Intelligence and SAT are now reachable, because v-structure was activated by Letter, a descendent of Grade
        expect(reachable).to eq ['Difficulty', 'Grade', 'Intelligence', 'SAT']
      end
    end
  end
end
