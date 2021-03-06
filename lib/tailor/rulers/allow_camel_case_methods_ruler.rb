require_relative '../ruler'

class Tailor
  module Rulers
    class AllowCamelCaseMethodsRuler < Tailor::Ruler
      def initialize(style, options)
        super(style, options)
        add_lexer_observers :ident
      end

      def ident_update(token, lexed_line, lineno, column)
        ident_index = lexed_line.event_index(column)
        previous_event = lexed_line.event_at(ident_index - 2)
        log "previous event: #{previous_event}"

        return if previous_event.nil?

        if previous_event[1] == :on_kw && previous_event.last == "def"
          measure(token, lineno, column)
        end
      end

      # Checks to see if the method name contains capital letters.
      #
      # @param [Fixnum] token The method name.
      # @param [Fixnum] lineno Line the problem was found on.
      # @param [Fixnum] column Column the problem was found on.
      def measure(token, lineno, column)
        if token.contains_capital_letter?
          problem_message = "Camel-case method name found."

          @problems << Problem.new(problem_type, lineno, column,
            problem_message, @options[:level])
        end
      end
    end
  end
end
