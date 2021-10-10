require_relative '../spec_helper'

describe MiniPGM::BayesianNetwork do
  let(:student_model) do
    described_class.new(
      MiniPGM::Edge.new('Difficulty', 'Grade'),
      MiniPGM::Edge.new('Intelligence', 'Grade'),
      MiniPGM::Edge.new('Intelligence', 'SAT'),
      MiniPGM::Edge.new('Grade', 'Letter'),
    )
  end

  describe '.new' do
    it 'detects cycles in a trivial case' do
      expect do
        described_class.new(
          MiniPGM::Edge.new('A', 'A')
        )
      end.to raise_error(MiniPGM::ModelError) { |e| expect(e.message).to include('cycle') }
    end

    it 'detects cycles in a non-trivial cases' do
      expect do
        described_class.new(
          MiniPGM::Edge.new('A', 'B'),
          MiniPGM::Edge.new('B', 'C'),
          MiniPGM::Edge.new('C', 'D'),
          MiniPGM::Edge.new('D', 'B'),
        )
      end.to raise_error(MiniPGM::ModelError) { |e| expect(e.message).to include('cycle') }
    end
  end

  describe '#d_separated?' do
    context 'Student Model' do
      context 'Difficulty' do
        it 'is d-separated from SAT when nothing is observed' do
          expect(student_model.d_separated?('Difficulty', 'SAT', []))
        end

        it 'is not d-separated when Grade is observed' do
          expect(student_model.d_separated?('Difficulty', 'SAT', ['Grade'])).to be_falsey
        end
      end
    end
  end

  describe '#reachable_from' do
    context 'Student Model' do
      context 'Difficulty' do
        it 'returns the correct list of labels when nothing is observed' do
          reachable = student_model.reachable_from('Difficulty', [])
          # Intelligence and SAT are blocked by a v-structure
          expect(reachable).to eq ['Difficulty', 'Grade', 'Letter']
        end

        it 'returns the correct list of labels when Grade is observed' do
          reachable = student_model.reachable_from('Difficulty', ['Grade'])
          # Intelligence and SAT are now reachable, because v-structure was activated by Grade
          expect(reachable).to eq ['Difficulty', 'Intelligence', 'SAT']
        end

        it 'returns the correct list of labels when Letter is observed' do
          reachable = student_model.reachable_from('Difficulty', ['Letter'])
          # Intelligence and SAT are now reachable, because v-structure was activated by Letter, a descendent of Grade
          expect(reachable).to eq ['Difficulty', 'Grade', 'Intelligence', 'SAT']
        end
      end
    end
  end

  describe '#to_factor' do

  end
end
