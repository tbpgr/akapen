# encoding: utf-8

module Akapen
  # = Akapen::Dsl
  class Dsl
    # == questions information
    attr_accessor :questions

    class << self
      # == get dynamic define field names.
      def get_dynamic_field_names
        Akapen::Dsl.instance_methods(false).delete_if { |e|e.match /(questions|method_missing)/ }.delete_if { |e|e.match /^_.*$/ }
      end
    end

    # == init Akapen::Dsl
    def initialize
      @questions = []
    end

    # == create dynamic define field or set question_ok or question_ng
    #- if you call qX_ok, call set_question_ok
    #- if you call qX_ng, call set_question_ng
    #- others, you define field by called name & value.
    def method_missing(method_name, *args, &block)
      arg = args[0]
      return if set_question_ok(method_name, arg)
      return if set_question_ng(method_name, arg)
      define_others(method_name, arg)
    end

    private
    def set_question_ok(method_name, ok_message)
      return unless method_name.to_s.match /^q(\d+)_ok$/

      ret = @questions.find { |qe|qe.no == Regexp.last_match[1] }
      if ret
        ret.ok = ok_message
      else
        q = Question.new(Regexp.last_match[1])
        q.ok = ok_message
        @questions << q
      end
      true
    end

    def set_question_ng(method_name, ng_message)
      return unless method_name.to_s.match /^q(\d+)_ng$/

      ret = @questions.find { |qe|qe.no == Regexp.last_match[1] }
      if ret
        ret.ng = ng_message
      else
        q = Question.new(Regexp.last_match[1])
        q.ng = ng_message
        @questions << q
      end
      true
    end

    def define_others(method_name, arg)
      self.class.class_eval "attr_accessor :_#{method_name}"
      self.class.class_eval <<-EOS
def #{method_name}(_#{method_name})
  @_#{method_name} = _#{method_name}
end
      EOS
      method("#{method_name}").call(arg)
    end
  end

  class Question
    attr_accessor :no, :ok, :ng
    def initialize(no)
      @no = no
    end
  end
end
