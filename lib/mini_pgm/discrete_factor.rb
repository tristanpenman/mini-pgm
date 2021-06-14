# frozen_string_literal: true

module MiniPGM
  #
  # Represents a discrete factor
  #
  # Example string representation:
  #
  #   +------+------+------+-----------------+
  #   |  x1  |  x2  |  x3  | phi(x1, x2, x3) |
  #   +------+------+------+-----------------+
  #   | x1_0 | x2_0 | x3_0 | 0.1             |
  #   +------+------+------+-----------------+
  #   | x1_0 | x2_0 | x3_1 | 0.3             |
  #   +------+------+------+-----------------+
  #   | x1_0 | x2_1 | x3_0 | 3.2             |
  #   +------+------+------+-----------------+
  #   | x1_0 | x2_1 | x3_1 | 3.3             |
  #   +------+------+------+-----------------+
  #   | x1_1 | x2_0 | x3_0 | 0.2             |
  #   +------+------+------+-----------------+
  #   | x1_1 | x2_0 | x3_1 | 4.9             |
  #   +------+------+------+-----------------+
  #   | x1_1 | x2_1 | x3_0 | 12.3            |
  #   +------+------+------+-----------------+
  #   | x1_1 | x2_1 | x3_1 | 4.0             |
  #   +------+------+------+-----------------+
  #
  class DiscreteFactor
    attr_reader :data, :variables

    def initialize(variables, data)
      expected_len = combinations(variables)
      raise ArgumentError, "wrong number of values; expected #{expected_len}" unless data.length == expected_len

      @variables = variables
      @data = data
    end

    def to_s
      MiniPGM::Printer.print([header(@variables), *body(@variables, @data)])
    end

    private

    def body(variables, data)
      num_rows = combinations(variables)
      num_labels = variables.size

      rows = Array.new(num_rows) { Array.new num_labels + 1 }

      cardinalities = variables.map(&:cardinality)
      counters = Array.new(num_labels, 0)

      rows.each.with_index do |row, index|
        # output current labels
        (0...num_labels).each do |column|
          row[column] = counters[column].to_s
        end

        # increment labels
        current_col = num_labels - 1
        while (counters[current_col] += 1) == cardinalities[current_col] && current_col.positive?
          counters[current_col] = 0
          current_col -= 1
        end

        # output data
        row[num_labels] = data[index].to_s
      end

      rows
    end

    def combinations(variables)
      variables.map(&:cardinality).inject(:*) || 1
    end

    def header(variables)
      labels = variables.map(&:label)
      labels.push("phi(#{labels.join(', ')})")
    end
  end
end
