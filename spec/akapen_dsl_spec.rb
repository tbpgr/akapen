# encoding: utf-8
require "spec_helper"
require "akapen_dsl"

describe Akapen::Dsl do
  context :method_missing do
    cases = [
      {
        case_no: 1,
        case_title: "single question",
        q_method_names: ["q1_ok", "q1_ng"],
        args: ["ok message", "ng message"],
        expected_nos: ["1"],
        expected_oks: ["ok message"],
        expected_ngs: ["ng message"],
      },
      {
        case_no: 2,
        case_title: "multi question",
        q_method_names: ["q1_ok", "q2_ok", "q1_ng", "q2_ng"],
        args: ["ok message1", "ok message2", "ng message1", "ng message2"],
        expected_nos: ["1", "2"],
        expected_oks: ["ok message1", "ok message2"],
        expected_ngs: ["ng message1", "ng message2"],
      },
      {
        case_no: 3,
        case_title: "other attributes",
        other_method_names: ["title", "summary"],
        args: ["this is title", "this is summary"],
        expected_others: ["this is title", "this is summary"],
      }
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          akapen_dsl = Akapen::Dsl.new

          # -- when --
          c[:q_method_names].each_with_index do |m, cnt|
            eval "akapen_dsl.#{c[:q_method_names][cnt]} \"#{c[:args][cnt]}\"", binding
          end if c[:q_method_names]

          c[:other_method_names].each_with_index do |m, cnt|
            eval "akapen_dsl.#{c[:other_method_names][cnt]} \"#{c[:args][cnt]}\"", binding
          end if c[:other_method_names]

          # -- then --
          c[:expected_nos].each_with_index do |m, cnt|
            actual = akapen_dsl.questions.find c[:expected_nos][cnt]
            expect(akapen_dsl.questions[cnt].no).to eq(c[:expected_nos][cnt])
            expect(akapen_dsl.questions[cnt].ok).to eq(c[:expected_oks][cnt])
            expect(akapen_dsl.questions[cnt].ng).to eq(c[:expected_ngs][cnt])
          end if c[:expected_nos]

          c[:expected_others].each_with_index do |m, cnt|
            actual = akapen_dsl.method("_#{c[:other_method_names][cnt]}").call
            expect(actual).to eq(m)
          end if c[:expected_others]
        ensure
          case_after c

        end
      end

      def case_before(c)
        # implement each case before

      end

      def case_after(c)
        # implement each case after
      end
    end
  end

end
