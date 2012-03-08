# RSpec for shell.rb
require '../lib/shell'
require 'stringio'

describe 'Shell' do
  describe 'prompt' do
    it 'should allow setting of prompt' do
      sh=Shell.new(:prompt=>'myprompt> ')
      sh.options.prompt.should=='myprompt> '
    end

    it 'should initialize with default prompt' do
      sh=Shell.new
      sh.options.prompt.should=='> '
    end
  end

  describe 'i/o streams' do
    it 'should allow setting of input stream' do
      sio = StringIO.new("test\nquit\n")
      sh=Shell.new(:prompt=>'> ', :input_stream=>sio)
      sh.options.input_stream.should==sio
    end

    it 'should use default stream: STDIN' do
      Shell.new.options.input_stream.should==STDIN #TODO: should abstract default stream
    end

    # Leave for another time when mock files in rspec are understood a bit better.
    it 'should read input from a file'
#      File.stubs!(:open).returns {StringIO.new("Test\nquit\n") }
#      File.stubs!(:gets).returns {}
#    end

    it 'should allow setting of output stream' do
      sio = StringIO.new("test\nquit\n")
      sout = StringIO.new
      sh=Shell.new(:prompt=>'> ', :input_stream=>sio, :output_stream=>sout)
      sh.options.output_stream.should==sout
    end

    it 'should default to STDOUT' do
      Shell.new.options.output_stream.should==STDOUT #TODO: should abstract default stream
    end
    
    it 'should be able to write to output stream' do    
      sout = StringIO.new
      sio = StringIO.new("quit\n")

      sh=Shell.new(:prompt=>'==> ', :output_stream=>sout, :input_stream=>sio)
      sh.run {|_| _}
      sout.string.should=='==> '
      sh.options.output_stream.string.should == '==> '      
    end
  end

end
