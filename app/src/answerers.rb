require_relative './hello.rb'
require_relative './scheduled_contest/answer.rb'
require_relative './random_problem/answer.rb'
require_relative './random_problem/duel.rb'

module Main
  class Answerers
    attr_accessor :objects
    def initialize
      @objects = [
        ScheduledContest::Answerer.new,
        RandomProblem::Answerer.new,
        Hello.new,
        RandomProblem::Duel.new
      ]
    end
  end
end
