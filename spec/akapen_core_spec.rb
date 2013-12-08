# encoding: utf-8
require "spec_helper"
require "akapen_core"

describe Akapen::Core do

  context :init do
    cases = [
      {
        case_no: 1,
        case_title: "init",
        expected_template: Akapen::Core::AKAPEN_TEMPLATE_TEMPLATE,
        expected_parameter: Akapen::Core::AKAPEN_PARAMETER_TEMPLATE,
        expected_checker: Akapen::Core::AKAPEN_CHECKER_TEMPLATE
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          akapen_core = Akapen::Core.new

          # -- when --
          akapen_core.init

          # then
          actual_template = File.open("#{Akapen::Core::AKAPEN_TEMPLATE_FILE}") {|f|f.read}
          actual_parameter = File.open("#{Akapen::Core::AKAPEN_PARAMETER_FILE}") {|f|f.read}
          actual_checker = File.open("#{Akapen::Core::AKAPEN_CHECKER_FILE}") {|f|f.read}
          expect(actual_template).to eq(c[:expected_template])
          expect(actual_parameter).to eq(c[:expected_parameter])
          expect(actual_checker).to eq(c[:expected_checker])
        ensure
          case_after c

        end
      end

      def case_before(c)
        # implement each case before

      end

      def case_after(c)
        # implement each case after
        File.delete(Akapen::Core::AKAPEN_TEMPLATE_FILE) if File.exists? Akapen::Core::AKAPEN_TEMPLATE_FILE
        File.delete(Akapen::Core::AKAPEN_PARAMETER_FILE) if File.exists? Akapen::Core::AKAPEN_PARAMETER_FILE
        File.delete(Akapen::Core::AKAPEN_CHECKER_FILE) if File.exists? Akapen::Core::AKAPEN_CHECKER_FILE
      end
    end
  end

  context :grade do
    AKAPEN_CHECKER_CASE1 =<<-EOS
class AkapenChecker
  # implement your check logic.(return true / false)
  def q1
    true
  end

  # implement your check logic.(return true / false)
  def q2
    false
  end

  # return answer users id. this is used in result file name.
  def id
    "some_id"
  end
end
    EOS

    AKAPEN_TEMPLATE_CASE1 =<<-EOS
Title   : <%=title%>
Summary : <%=summary%>

Your Answers
<%=q_results%>

Thank you for challenge!
    EOS

    AKAPEN_PARAMETER_CASE1 =<<-END
title "Some Title"
summary "Some Summary"

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

    AKAPEN_RESULT_CASE1 =<<-EOS
Title   : Some Title
Summary : Some Summary

Your Answers
question1: ok
question2: ng

Thank you for challenge!
    EOS

    cases = [
      {
        case_no: 1,
        case_title: "case_title",
        id: "some_id",
        akapen_checker: AKAPEN_CHECKER_CASE1,
        akapen_template: AKAPEN_TEMPLATE_CASE1,
        akapen_parameter: AKAPEN_PARAMETER_CASE1,
        expected: AKAPEN_RESULT_CASE1,
      },

      # Templateなしのケース
      # Parameterなしのケース
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          akapen_core = Akapen::Core.new

          # -- when --
          akapen_core.grade

          # -- then --
          result_file = Akapen::Core::AKAPEN_RESULT_FILE.gsub('$id$', c[:id])

          FileTest.exist?("./#{result_file}").should be_true
          actual = File.read(result_file)
          expect(actual).to eq(c[:expected])
        ensure
          case_after c

        end
      end

      def case_before(c)
        # implement each case before
        File.open("./#{Akapen::Core::AKAPEN_CHECKER_FILE}", "w") {|f|f.puts c[:akapen_checker]}
        File.open("./#{Akapen::Core::AKAPEN_TEMPLATE_FILE}", "w") {|f|f.puts c[:akapen_template]}
        File.open("./#{Akapen::Core::AKAPEN_PARAMETER_FILE}", "w") {|f|f.puts c[:akapen_parameter]}
      end

      def case_after(c)
        # implement each case after
        File.delete(Akapen::Core::AKAPEN_TEMPLATE_FILE) if File.exists? Akapen::Core::AKAPEN_TEMPLATE_FILE
        File.delete(Akapen::Core::AKAPEN_PARAMETER_FILE) if File.exists? Akapen::Core::AKAPEN_PARAMETER_FILE
        File.delete(Akapen::Core::AKAPEN_CHECKER_FILE) if File.exists? Akapen::Core::AKAPEN_CHECKER_FILE
        File.delete(Akapen::Core::AKAPEN_RESULT_FILE.gsub('$id$', c[:id])) if File.exists? Akapen::Core::AKAPEN_RESULT_FILE.gsub('$id$', c[:id])
      end
    end
  end
end
