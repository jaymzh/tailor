require 'erb'
require 'yaml'
require 'fileutils'
require_relative 'runtime_error'
require_relative 'logger'
require_relative 'lexer'
require_relative 'configuration'
require_relative 'ruler'
require_relative 'rulers'


class Tailor
  class Critic
    include LogSwitch::Mixin
    include Tailor::Rulers

    def initialize(configuration)
      @config = configuration
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    # @return [Hash] The Problems for that file.
    def check_file file
      log "<#{self.class}> Checking style of a single file: #{file}."
      lexer = Tailor::Lexer.new(file)
      
      ruler = Ruler.new
      h_spacing_ruler = HorizontalSpacingRuler.
        new(@config[:horizontal_spacing])
      v_spacing_ruler = VerticalSpacingRuler.new(@config[:vertical_spacing])
      indentation_ruler = IndentationRuler.new(@config[:indentation])
      indentation_ruler.start
      
      ruler.add_child_ruler(h_spacing_ruler)
      ruler.add_child_ruler(v_spacing_ruler)
      ruler.add_child_ruler(indentation_ruler)

      if @config[:horizontal_spacing]
        unless @config[:horizontal_spacing][:allow_hard_tabs]
          hard_tab_ruler = HardTabRuler.new
          h_spacing_ruler.add_child_ruler(hard_tab_ruler)
          lexer.add_sp_observer(hard_tab_ruler)
        end
      end

      lexer.add_file_observer v_spacing_ruler
      lexer.add_comma_observer indentation_ruler
      lexer.add_comma_observer h_spacing_ruler
      lexer.add_embexpr_beg_observer indentation_ruler
      lexer.add_embexpr_end_observer indentation_ruler
      lexer.add_ignored_nl_observer indentation_ruler
      lexer.add_ignored_nl_observer h_spacing_ruler
      lexer.add_kw_observer indentation_ruler
      lexer.add_lbrace_observer indentation_ruler
      lexer.add_lbracket_observer indentation_ruler
      lexer.add_lparen_observer indentation_ruler
      lexer.add_nl_observer indentation_ruler
      lexer.add_nl_observer h_spacing_ruler
      lexer.add_period_observer indentation_ruler
      lexer.add_rbrace_observer indentation_ruler
      lexer.add_rbracket_observer indentation_ruler
      lexer.add_rparen_observer indentation_ruler
      lexer.add_tstring_beg_observer indentation_ruler
      lexer.add_tstring_end_observer indentation_ruler
      
      lexer.lex
      lexer.check_added_newline
      
      problems[file] = ruler.problems

      { file => problems[file] }
    end
    
    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      if problems.empty?
        puts "Your files are in style."
      else
        summary_table = Text::Table.new
        summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
        summary_table.rows << [{ value: "File", align: :center },
          { value: "Total Problems", align: :center }]
        summary_table.rows << :separator

        problems.each do |file, problem_list|
          unless problem_list.empty?
            print_file_problems(file, problem_list)
          end

          summary_table.rows << [file, problem_list.size]
        end

        puts summary_table
      end
    end

    # @return [Hash]
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.values.flatten.size
    end

    # Checks to see if +path_to_check+ is a real file or directory.
    #
    # @param [String] path_to_check
    # @return [Boolean]
    def checkable? path_to_check
      File.file?(path_to_check) || File.directory?(path_to_check)
    end
  end
end
