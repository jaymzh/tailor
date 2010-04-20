module RubyStyleChecker


  # Calling modules will get the Ruby file to check, then read by line.  This 
  #   class allows for checking of line-specific style by Represents a single 
  #   line of a file of Ruby code.  Inherits from String so "self" can be used.
  class FileLine < String
    
    # This passes the line of code to String (the parent) so that it can act
    #   like a standard string.
    #
    # @param [String] line_of_code Line from a Ruby file that will be checked 
    #   for styling.
    # @return [String] Returns a String that includes all of the methods 
    #   defined here.
    def initialize line_of_code
      super line_of_code
    end

    # Determines the number of spaces the line is indented.
    # 
    # @return [Number] Returns the number of spaces the line is indented.
    def indented_spaces
      # Find out how many spaces exist at the beginning of the line
      spaces = self.scan(/^\x20+/).first

      unless spaces.nil?
        return spaces.length
      else
        return 0
      end
    end

    # Checks to see if the source code line is tabbed
    # 
    # @return [Boolean] Returns true if the file contains a tab
    #   character before any others in that line.
    def hard_tabbed?
      result = case self
        # The line starts with a tab
        when /^\t/ then true
        # The line starts with spaces, then has a tab
        when /^\s+\t/ then true
        else false
      end
    end

    # Checks to see if the method is using camel case.
    # 
    # @return [Boolean] Returns true if the method name is camel case.
    def camel_case?
      # Make sure we're dealing with a method before evaluating.
      if self.method?
        words = self.split(/ /)

        # The 2nd word is the method name, so evaluate that.
        if words[1] =~ /[A-Z]/
          return true
        else
          return false
        end
      end
    end

    # Checks to see if the line is the start of a method's definition.
    # 
    # @return [Boolean] Returns true if the line contains 'def' and the second word
    #   begins with a lowercase letter.
    def method?
      words = self.split(/ /)
      if words[0].eql? "def" and starts_with_lowercase?(words[1])
        return true
      else
        return false
      end
    end

    #-----------------------------------------------------------------
    # Private methods
    #-----------------------------------------------------------------
    private
    
    # Checks to see if a word begins with a lowercase letter.
    # 
    # @param [String] word The word to check case on.
    def starts_with_lowercase? word
      if word =~ /^[a-z]/
        return true
      else
        return false
      end
    end
  end
end