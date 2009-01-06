require 'yaml'
require 'erb'

module I18n
  module Backend
    class Erb < I18n::Backend::Simple
      protected
      def load_yml(filename)
        erb = ERB.new(IO.read(filename))
        erb.filename = filename
        text = erb.result
        YAML::load(text)
      end
    end
  end
end
