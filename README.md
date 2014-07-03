# Akapen

[![Gem Version](https://badge.fury.io/rb/akapen.svg)](http://badge.fury.io/rb/akapen)

Akapen is grading & report generator.

## Summary

If you have some students, and you have to check student's test or some report constantly,

Akapen help your operation more easily.

you have to do is

* create test check script each question.

* create result report template

* create ok/ng message for each question.

after setting, Akapen check test & create report automatically.

## Installation

Add this line to your application's Gemfile:

    gem 'akapen'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install akapen

## Structure
### Image
<img src="./doc_image/akapen structure.png" />

### akapen_checker.rb
this is test check script.

if you execute 'akapen init', you can get this files's template.

but you want to create empty new file, you can.

you must implement this class/methods.

each questions method must name 'qX', and must return true/false.

(※X = serial number from 1. for example q1, q2 ...)

you have to implement id method, to distinguish each submitter.

id is considered for multi student's tests or reports check.

sample
~~~ruby
# encoding: utf-8
class AkapenChecker
  # implement your check logic.(return true / false)
  def q1
    # some check logic that returns true/false
    # you can implement this logic by ruby.
    # you can implement this logic by another language.
    # if you use another language, you can get result following command
    # let = `some command`
  end

  # implement your check logic.(return true / false)
  def q2
    # some check logic that returns true/false
  end

  # if you want create more questions, you can create q3,q4...

  # return answer users id. this is used in result file name.
  def id
     # some id get logic that returns String id.
  end
end
~~~

### Questiontemplate
write your report templete by ERB format.

if you execute 'akapen init', you can get this files's template.

but you want to create new empty file, you can.

if you use <%=q_results%>, you can get each test or report result messages.

other parameter can freely use.

parameter's contents must write in Questionparameter, and must git it same variable name.

sample
~~~erb
Title: <%=title%>
Summary: <%=summary%>

Results
<%=q_results%>

Thanks!!
~~~

### Questionparameter
write your report parameter for Questiontemplate.

if you execute 'akapen init', you can get this files's template.

but you want to create new empty file, you can.

you have to define each test result message q1_ok, q1_ng, q2_ok, q2_ng, q3....

sample
~~~ruby
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
~~~

## Usage
### akapen init
if you execute akapen init, you can get template files [akapen_checker.rb, Questiontemplate, Questionparameter]
~~~bash
akapen init
~~~

### akapen grade
before execute this command, you must create [akapen_checker.rb, Questiontemplate, Questionparameter].

[akapen_checker.rb, Questiontemplate, Questionparameter] can get by 'akapen init' command.

if you execute akapen grade, you can get grading result report 'akapen_result_id.txt' in current directory.
~~~bash
akapen grade
~~~

## Pragmatic Usage
### 1. Generate Template Files by akapen init
~~~bash
akapen init
~~~

after generate
~~~bash
akapen_checker.rb
Akapenparameter
Akapentemplate
~~~

akapen_checker.rb
~~~ruby
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
~~~

Akapenparameter
~~~ruby
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
~~~

Akapentemplate
~~~erb
# write your result report template by erb format.

# if you want to use each questions response,
# use <%=q_results%>.

# if you want to use some parameter, any word you can use.
# for example
# title: <%=title%>
# summary: <%=summary%>
~~~

### 2. Edit akapen_checker.rb
~~~ruby
# encoding: utf-8
class AkapenChecker
  # implement your check logic.(return true / false)
  def q1
    # actually , you must implement boolean test check logic.
    false
  end

  # implement your check logic.(return true / false)
  def q2
    # actually , you must implement boolean test check logic.
    true
  end

  # return answer users id. this is used in result file name.
  def id
    # actually , you must get id information from some file.
    "some_id"
  end
end
~~~

### 3. Edit Akapentemplate
set your report template message.
~~~erb
Title: <%=title%>
Summary: <%=summary%>

Results
<%=q_results%>

Thanks!!
~~~

### 4. Edit Akapenparameter
set your variable messages for Akapentemplate.

~~~ruby
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
~~~

### 5. Execute akapen grade
~~~bash
akapen grade
~~~

### 6. check your report
~~~bash
$ tree
  Akapenparameter
  Akapentemplate
  akapen_checker.rb
  akapen_result_some_id.txt

$ cat akapen_result_some_id.txt
Title: some title
Summary: some summary

Results
question1: ng
question2: ok

Thanks!!
~~~

## History
* version 0.0.1 : first release.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
