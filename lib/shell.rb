#shell.rb
require 'ostruct'

class Shell
  attr_reader :options
  def initialize conf={}
    @options=OpenStruct.new conf
    # Setup any required options with sensible defaults, unless specified
    # during creation.
    @options.prompt ||= '> '
    @options.input_stream ||= STDIN
    @options.output_stream ||= STDOUT
  end

  def run &blk    
    val = 0
    loop do
      prompt_user
      user_input = get_user_input
      case user_input
      when /^(q(uit)?|\s*)$/i
        val= :quit
        break;
      else        
        val = yield user_input
      end      
    end 
    val
  end

private

  def prompt_user
    @options.output_stream.print options.prompt
  end

  def get_user_input
    @options.input_stream.gets.chomp
  end

end
