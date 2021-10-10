require_relative '../spec_helper'

describe MiniPGM::MarkovNetwork do
  let(:simple_model) do
    described_class.new(
      MiniPGM::Edge.new('A', 'B'),
      MiniPGM::Edge.new('B', 'C'),
      MiniPGM::Edge.new('C', 'D'),
      MiniPGM::Edge.new('D', 'A')
    )
  end

  describe '.new' do
    it 'works in a simple case' do
      expect do
        described_class.new(
          MiniPGM::Edge.new('C', 'A'),
          MiniPGM::Edge.new('B', 'A'),
          MiniPGM::Edge.new('B', 'C')
        )
      end.to_not raise_exception
    end

    it 'detects duplicate edges' do
      expect do
        described_class.new(
          MiniPGM::Edge.new('A', 'B'),
          MiniPGM::Edge.new('B', 'C'),
          MiniPGM::Edge.new('C', 'D'),
          MiniPGM::Edge.new('D', 'A'),
          MiniPGM::Edge.new('D', 'A')
        )
      end.to raise_error(MiniPGM::ModelError) { |e| expect(e.message).to include('duplicate') }
    end
  end
end
