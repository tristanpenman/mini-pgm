# Plan

## Basics

  - [x] Define a tabular CPD (conditional probability distribution)
    - [x] Variable name
    - [x] Variable cardinality (i.e. how many different states can the variable take)
    - [x] Evidence variables
    - [x] Evidence variable cardinalities (implicit in those variables)
  - [x] Define a tabular CPD that does not require evidence
  - [x] Define a model
  - [x] Add CPDs to a model
    - [x] There is an implicit constraint in the CPDs, in that they must satisfy the structure of the model
  - [ ] Functions to:
    - [x] Determine D-separation
    - [ ] Convert to markov model
    - [x] Determine active trails
    - [ ] Determine local independencies
    - [ ] Get independencies

## Markov Networks

  Markov network is parameterised by factors representing the likelihood of the state of one variable to agree with the state of another.

  A factor has:

  - Variables
  - Variable cardinality
  - Values

  TODO
  
  - [ ] Basic implementation
  - [ ] Conversion to Bayesian network
  - [ ] Get partition function

## Inference
  
  - [ ] Variable elimination
    - [ ] Query specific variables
    - [ ] With given evidence
  - [ ] MAP queries

## Fit and predict

  - TODO

## Sampling

  - [ ] Forward sampling in a discrete-CPD Bayesian network
  - [ ] Forward sampling in a linear Gaussian-CPD Bayesian network
  - [ ] Forward sampling in a hybrid (any CPD type) Bayesian network
  - [ ] Forward sampling in a dynamic 2-TBN Bayesian network
  - [ ] Gibbs sampling in a discrete-CPD Bayesian network (given evidence)