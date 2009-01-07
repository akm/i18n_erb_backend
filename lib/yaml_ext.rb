# -*- coding: utf-8 -*-
module YAML
  class << self
    def insert_text_with_indent(io, indent = 0)
      result = "\n"
      head_space = ' ' * indent
      io.each_line do |line|
        result << head_space << line.gsub(/\s+$/, '') << "\n" 
      end
      result
    end
    
    def insert_text_file(path, indent = 0)
      result = nil
      open(File.join(path)) do |f|
        result = insert_text_with_indent(f, indent)
      end
      result
    end
    
    def insert_object(object, options = nil)
      options = { 
        :indent => 0
      }.update(options || {})
      text = YAML.dump(object).gsub(/^---/, '')
      insert_text_with_indent(StringIO.new(text), options[:indent])
    end
    
    def to_properties(filename)
      result = ''
      erb = ERB.new(IO.read(filename))
      erb.filename = filename
      text = erb.result
      prefixes = []
      StringIO.new(text).each_line do |line|
        line = line.gsub(/\s*$/, '')
        case line
        when /^[\s\t]*$/
          # do nothing
        when /^\s*\#/
          result << line.strip
        when /\:$/
          position = line.scan(/^\s*/).first.count(' ') / 2
          name = line.gsub(/\:$/, '').strip
          prefixes = prefixes[0..(position - 1)] + [name]
          result << '# ' << line
        else
          position = line.scan(/^\s*/).first.count(' ') / 2
          key, value = *line.split(':', 2).map{|s| s.strip}
          value.gsub!(/^\"|\"$/, '')
          result << (prefixes[0..(position - 1)] + [key]).join('.') << '=' << value
        end
        result << "\n"
      end
      result
    end
    
    def from_properties(filename)
      result = ''
      erb = ERB.new(IO.read(filename))
      erb.filename = filename
      text = erb.result
      prefixes = []
      StringIO.new(text).each_line do |line|
        line = line.gsub(/^\s|\s*$/, '')
        case line
        when /^[\s\t]*$/
          # do nothing
        when /^\s*\#.*\:\s*$/ # to_propertiesで入れたコメントは無視
          next
        when /^\s*\#/
          result << line.strip
        when /\=/
          keys, value = line.split('=', 2)
          paths = keys.split('.')
          key = paths.pop
          path_matching = true
          paths.each_with_index do |path, index|
            path_matching = (path == prefixes[index]) if path_matching
            unless path_matching
              result << (' ' * 2 * index) << path << ':' << "\n"
            end
          end
          prefixes = paths
          value = (/^\d+$|^\[.*\]$/ =~ value) ? value : '"%s"' % value
          result << (' ' * 2 * paths.length) << key << ': ' << value
        else
          result << line
        end
        result << "\n"
      end
      result
    end
  end
end
