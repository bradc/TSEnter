require './lib/tsenter'

# CommandLine will process program switches, if/when needed
# for now it simply strips off any switches and concatenates 
# the remaining.  Assuming the remaining is a ts entry.
args = CommandLine.new(ARGV)
# Assume some default entries, such as default local data store
# we'll assume for now that KirbyBase will be used as the local
# store.
config = TS::Configure.new do |conf|
	# Only adapter for now, later will be updated to handle other
	# commandline configurations. 
	# E.g. of setting a text editor for long descriptions.	
	#  conf.editor='notepad.exe'
	conf.db= DataStore.new(:adapter=>:KirbyBase, :local=>true)
end
TS::Enter.new(config).start(args)
