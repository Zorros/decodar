module Decodar
  module Record
    class Base
      class << self
        attr_accessor :specified_codes
        attr_reader   :identifier, :article_identifier
      end

      def self.inherited(base)
        base.instance_eval do
          @specified_codes = {}
        end
      end

      def self.specify_code(name, position, type, allow_blank = true)
        code_reader(name)
        @specified_codes[name] = CodeSpecification.new(self.name, name, position, type, allow_blank)
      end

      def self.code_reader(name)
        define_method(name) do
          @codes[name]
        end
      end

      def self.specify_identifier(identifier, article_identifier = nil)
        @identifier = identifier
        @article_identifier = article_identifier
        Decodar::Lexer.instance.register_record(self)
      end

      def initialize(raw_record, line_number)
        @codes      = {}
        @raw_record = raw_record
        @line_number = line_number
        read
      end

      def to_s
        result = "#{self.class.name} - #{@line_number}\n"
        @codes.each do |k, v|
          result << "  :#{k} => #{v.inspect}\n"
        end
        result
      end

      private
        def read
          self.class.specified_codes.each do |name, specification|
            @codes[name] = specification.extract_formatted_code(@raw_record)
          end
        end
    end
  end
end