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
  end
end
