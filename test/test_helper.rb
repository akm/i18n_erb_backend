$KCODE='u'
require 'test/unit'

require 'rubygems'
gem 'activesupport', '>=2.2.2'
require 'activesupport'
require 'yaml_waml' rescue nil

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require File.join(File.dirname(__FILE__), '..', 'init')
