require "akapen/version"
require "akapen_dsl"
require "erb"

module Akapen
  #= Akapen::Core
  class Core
    #== result file name
    AKAPEN_RESULT_FILE = "akapen_result_$id$.txt"
    #== check script template file name
    AKAPEN_CHECKER_FILE = "akapen_checker.rb"
    #== check script template
    AKAPEN_CHECKER_TEMPLATE =<<-EOS
# encoding: utf-8
class AkapenChecker
  # implement your check logic.(return true / false)
  def q1
    true
  end

  # implement your check logic.(return true / false)
  # def q2
  #   true
  # end

  # return answer users id. this is used in result file name.
  def id
    "some_id"
  end
end
    EOS

    #== report template file name
    AKAPEN_TEMPLATE_FILE = "Akapentemplate"
    #== report template template
    AKAPEN_TEMPLATE_TEMPLATE =<<-EOS
# write your result report template by erb format.

# if you want to use each questions response,
# use <%=q_results%>.

# if you want to use some parameter, any word you can use.
# for example
# title: <%=title%>
# summary: <%=summary%>
    EOS

    #== report parameter template file name
    AKAPEN_PARAMETER_FILE = "Akapenparameter"
    #== report parameter template
    AKAPEN_PARAMETER_TEMPLATE =<<-END
title "some title"
summary "some summary"

q1_ok <<-EOS
question1: ok
EOS
q1_ng <<-EOS
question1: ng
EOS

q2_ok <<-EOS
question2: ok
EOS
q2_ng <<-EOS
question2: ng
EOS
    END

    # init Akapen::Core
    def init
      File.open("./#{AKAPEN_CHECKER_FILE}", "w") {|f|f.puts AKAPEN_CHECKER_TEMPLATE}
      File.open("./#{AKAPEN_TEMPLATE_FILE}", "w") {|f|f.puts AKAPEN_TEMPLATE_TEMPLATE}
      File.open("./#{AKAPEN_PARAMETER_FILE}", "w") {|f|f.puts AKAPEN_PARAMETER_TEMPLATE}
    end

    # check test or report, and generate result report from Akapentemplate & Akapenparameter.
    def grade
      require "./akapen_checker"
      template = read_template
      parameters = read_parameters
      dsl = Dsl.new
      dsl.instance_eval parameters
      
      test_results = get_test_results
      id = get_id
      q_results = get_q_results(dsl, test_results)
      result = get_report(dsl, q_results, template)
      File.open(get_output_filename(id), "w") {|f|f.puts result}
    end

    private
    def read_template
      unless File.exists? "./#{AKAPEN_TEMPLATE_FILE}"
        raise AkapenTemplateNotExistsError.new("you must create #{AKAPEN_TEMPLATE_FILE}. create manually or execute 'akapen init' command")
      end

      File.open("./#{AKAPEN_TEMPLATE_FILE}", "r:utf-8") { |f|f.read }
    end

    def read_parameters
      AKAPEN_PARAMETER_FILE
      unless File.exists? "./#{AKAPEN_PARAMETER_FILE}"
        raise AkapenTemplateNotExistsError.new("you must create #{AKAPEN_PARAMETER_FILE}. create manually or execute 'akapen init' command")
      end

      File.open("./#{AKAPEN_PARAMETER_FILE}", "r:utf-8") { |f|f.read }
    end

    def get_test_results
      akapen_checker = AkapenChecker.new
      test_results = []
      AkapenChecker.instance_methods.grep(/^q(\d+)$/).sort.each do |m|
        test_results << akapen_checker.method(m).call
      end
      test_results
    end

    def get_id
      AkapenChecker.new.id
    end

    def get_q_results(dsl, test_results)
      questions = dsl.questions
      ret = []

      test_results.each_with_index do |result, index|
        if (result)
          ret << questions[index].ok
        else
          ret << questions[index].ng
        end
      end
      ret.join.chomp
    end

    def get_report(dsl, q_results, template)
      dynamic_filed_names = Akapen::Dsl.get_dynamic_field_names
      code = []
      dynamic_filed_names.each do |field_name|
        method_value = dsl.method("_#{field_name}").call
        code << "#{field_name.to_s} = '#{method_value}'"
      end
      code << "erb = ERB.new(template)"
      code << "erb.result(binding)"
      eval code.join("\n"), binding
    end

    def get_output_filename(id)
      AKAPEN_RESULT_FILE.gsub('$id$', id)
    end
  end

  class AkapenTemplateNotExistsError < StandardError;end
  class AkapenParameterNotExistsError < StandardError;end
end
