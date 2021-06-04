# frozen_string_literal: true

module MiniPGM
  #
  # Represents a variable in a tabular CPD
  #
  Variable = Struct.new(:label, :cardinality)
end
