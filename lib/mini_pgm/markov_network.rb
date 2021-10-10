# frozen_string_literal: true

module MiniPGM
  #
  # An undirected graph representing a Markov Network
  #
  class MarkovNetwork
    #
    # Edges between individual nodes, sorted by label of the outgoing edge, e.g:
    #
    #   Cancer -- Pollution
    #   Cancer -- Smoker
    #
    attr_reader :edges

    #
    # Lookup table of labelled nodes, each associated with a set of labels for all incoming edges, e.g:
    #
    #   { Pollution, Smoker } -- Cancer -- { }
    #   { } -- Pollution -- { Cancer }
    #   { } -- Smoker -- { Cancer }
    #
    attr_reader :nodes

    #
    # TODO
    #
    attr_reader :factors

    def initialize(*edges)
      @factors = []
      @edges = sort_edges(edges)
      @nodes = reduce_edges(edges)

      dupe = find_duplicate_edge
      raise ModelError, "graph contains a duplicate edge: #{dupe}" if dupe
    end

    def add_factor(factor)
      @factors << factor
    end

    def to_s
      ['Edges:', edges_to_s, '',
       'Nodes:', nodes_to_s, '',
       'Factors:', factors_to_s, '',
       'Valid:', valid?(set_error: false), ''].join("\n")
    end

    def validate!
      # TODO
    end

    def valid?(set_error: true)
      @error = nil
      validate!
      true
    rescue ValidationError => e
      @error = e if set_error
      false
    end

    private

    def find_duplicate_edge
      canonicalised = edges.map(&:canonicalise)
      canonicalised.detect { |edge| canonicalised.count(edge) > 1 }
    end

    def edge_to_s(edge)
      "#{edge.from} -- #{edge.to}"
    end

    def edges_to_s
      @edges.map { |edge| edge_to_s(edge) }.join("\n")
    end

    def factors_to_s
      @factors.map(&:to_s).join("\n")
    end

    def node_to_s(node)
      [write_set(node.incoming_edges), node.label, write_set(node.outgoing_edges)].join(' -- ')
    end

    def nodes_to_s
      @nodes.keys.sort.map { |key| node_to_s(@nodes[key]) }.join("\n")
    end

    def reduce_edges(edges)
      edges.each_with_object({}) do |edge, reduced|
        # create node for incoming edge
        (reduced[edge.to] ||= MiniPGM::Node.new(edge.to)).incoming_edges.add(edge.from)

        # create node for outgoing edge
        (reduced[edge.from] ||= MiniPGM::Node.new(edge.from)).outgoing_edges.add(edge.to)
      end
    end

    def sort_edges(edges)
      edges.sort_by { |edge| [edge.from, edge.to] }
    end

    def write_set(set)
      set.empty? ? '{ }' : "{ #{set.to_a.sort.join(', ')} }"
    end
  end
end
