# frozen_string_literal: true

require_relative 'model_error'
require_relative 'node'

module MiniPGM
  #
  # Represents a bayesian network
  #
  class BayesianNetwork
    #
    # Edges between individual nodes, sorted by label of the outgoing edge, e.g:
    #
    #   Pollution -> Cancer
    #   Smoker -> Cancer
    #
    attr_reader :edges

    #
    # Lookup table of labelled nodes, each associated with a set of labels for all incoming edges, e.g:
    #
    #   { Pollution, Smoker } -> Cancer -> { }
    #   { } -> Pollution -> { Cancer }
    #   { } -> Smoker -> { Cancer }
    #
    attr_reader :nodes

    # most recent error after calling `valid?`
    attr_reader :error

    def initialize(*edges)
      @edges = sort_edges(edges)
      @nodes = reduce_edges(edges)
    end

    def add_cpd(cpd)
      node = @nodes[cpd.variable.label]
      raise ArgumentError, "node does not exist for label #{cpd.variable.label}" unless node

      check_cpd_evidence!(cpd.evidence.map(&:label), node.incoming_edges)
      node.cpd = cpd
    end

    def to_s
      ['Edges:', edges_to_s, '', 'Nodes:', nodes_to_s, '', 'Valid:', valid?(false), ''].join("\n")
    end

    def validate!
      cyclic_node = find_cyclic_node
      raise ModelError, "graph contains a cycle, found at node: #{cyclic_node}" if cyclic_node

      @nodes.each_value do |node|
        raise ModelError, "node '#{node.label}' does not have a CPD" unless node.cpd
      end

      # validate cardinality between nodes for each edge
      @edges.each do |edge|
        validate_cardinality!(@nodes[edge.to], @nodes[edge.from])
      end
    end

    def valid?(set_error = true)
      @error = nil
      validate!
      true
    rescue ModelError => e
      @error = e if set_error
      false
    end

    private

    def check_cpd_evidence!(cpd_evidence, node_dependencies)
      cpd_evidence.each do |evidence|
        raise ArgumentError, "node is missing dependency for CPD evidence '#{evidence}'" \
          unless node_dependencies.include?(evidence)
      end

      node_dependencies.each do |dependency|
        raise ArgumentError, "CPD is missing evidence for node dependency '#{dependency}'" \
          unless cpd_evidence.include?(dependency)
      end
    end

    def edges_to_s
      @edges.map(&:to_s).join("\n")
    end

    # recursive method to find cycles using depth first search
    def find_cyclic_node(labels = @nodes.keys, visited = Set.new, current = Set.new)
      labels.each do |label|
        node = @nodes[label]

        # already visited this node on the current path
        return node if current.include?(node)

        # already visited this node naturally
        next if visited.include?(node)

        visited.add(node)
        current.add(node)

        cycle = find_cyclic_node(node.outgoing_edges, visited, current)
        return cycle if cycle

        current.delete(node)
      end
      nil
    end

    def nodes_to_s
      @nodes.keys.sort.map { |key| @nodes[key].to_s }.join("\n")
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
      edges.sort_by(&:from)
    end

    def validate_cardinality!(to, from)
      expected = to.cpd.evidence.find { |ev| ev.label == from.label }.cardinality
      actual = from.cpd.variable.cardinality

      raise ModelError, "cardinality mismatch in CPDs of '#{from.label}' (#{actual}) and '#{to.label}' (#{expected})" \
        unless expected == actual
    end
  end
end
