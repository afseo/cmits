# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
require 'test/unit'
require 'open3'
require 'erb'

class TestSudoSyntax < Test::Unit::TestCase
  def test_all_templates_sudo_syntax
    templates = File.join(File.dirname(__FILE__), '..', 'templates')
    all_templates = Dir[File.join(templates, '*')]
    all_templates.reject! {|x| File.basename(x) =~ /~$/ }
    all_templates.reject! {|x| File.basename(x) =~ /^#/ }
    all_templates.reject! {|x| File.basename(x) =~ /^\./ }
    all_templates.reject! {|x| not File.file? x }
    all_templates.each do |template|
      template = File.expand_path(template)
      contents = File.read(template)
      # we are not sure what values the template attempts to get from
      # its surrounding environment. so we evaluate it, catching the
      # NameError raised and defining the thing that could not be
      # found to a nonce value, until there are no more problems.
      problems = true
      # hackery!
      # http://ciaranm.wordpress.com/2009/03/31/feeding-erb-useful-variables-a-horrible-hack-involving-bindings/
      neededValues = Module.new
      b = neededValues.instance_eval { binding }
      # ASSUMPTION: all substitutions in the template are single
      # values, not things that get looped over!
      while problems
        e = ERB.new(contents)
        begin
          e.result b
          problems = false
        rescue NameError => ex
          problems = true
          if ex.message =~ /`([^']+)'/
            name = $1
            neededValues.instance_eval do
              mnv = class << self; self; end
              mnv.send(:define_method, name) do
                "value_for_#{name}_eh"
              end
            end
          else
            raise
          end
        end
      end
      # now we can evaluate the template without error
      final_text = e.result b
      # now check the syntax
      error_output = ''
      Open3.popen3('visudo', '-c', '-f', '-') do |si, so, se|
        si.print final_text
        si.close
        error_output = se.read
      end
      assert error_output == '', "syntax problem found in #{template}: #{error_output}"
    end
  end
end
