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
    
    def to_properties(filename, erb_enabled = false)
      result = ''
      text = nil
      if erb_enabled
        erb = ERB.new(IO.read(filename))
        erb.filename = filename
        text = erb.result
      else
        text = IO.read(filename)
      end
      prefixes = []
      StringIO.new(text).each_line do |line|
        backslash_tail = /\\\s*$/ =~ line
        line = line.gsub(/\s*\\{0,1}$/, '')
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
          if value
            value.gsub!(/^\"|\"$/, '')
            result << (prefixes[0..(position - 1)] + [key]).join('.') << '=' << value
          else
            result << line.strip.gsub(/^\"|\"$/, '')
          end
          result << '\\' if backslash_tail
        end
        result << "\n"
      end
      result
    end
    
    def from_properties(filename, erb_enabled = false)
      result = ''
      text = nil
      if erb_enabled
        erb = ERB.new(IO.read(filename))
        erb.filename = filename
        text = erb.result
      else
        text = IO.read(filename)
      end
      prefixes = []
      in_multiline = false
      StringIO.new(text).each_line do |line|
        backslash_tail = /\\\s*$/ =~ line
        line = line.gsub(/\s*\\{0,1}$/, '')
        if in_multiline
          result << (' ' * 2 * (prefixes.length + 1)) << line
          result << '\\' if backslash_tail
          result << '"' unless backslash_tail
        else
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
            unless /^\d+$|^\[.*\]$/ =~ value
              value = (backslash_tail ?  '"%s' : '"%s"') % value
            end
            result << (' ' * 2 * paths.length) << key << ': ' << value
            result << '\\' if backslash_tail
          else
            result << line
          end
        end
        result << "\n"
        in_multiline = backslash_tail
      end
      result
    end
  end
end
