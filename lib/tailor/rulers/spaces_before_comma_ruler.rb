require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesBeforeCommaRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @comma_columns = []
      end
      
      def comma_update(text_line, lineno, column)
        @comma_columns << column
      end

      def check_spaces_before_comma(lexed_line, lineno)
        @comma_columns.each do |c|
          column_event = lexed_line.event_at(c)
          event_index = lexed_line.index(column_event)
          previous_event = lexed_line.at(event_index - 1)
          actual_spaces = previous_event[1] != :on_sp ? 0 : previous_event.last.size
          
          if actual_spaces != @config
            @problems << Problem.new(:spaces_before_comma, lineno, c - 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_before_comma(lexed_line, lineno)
      end
      
      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end
    end
  end
end
