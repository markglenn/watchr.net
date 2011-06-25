#!/usr/bin/ruby

# This class helps call growlnotify with the given parameters.
class GrowlNotifier

  # Executes growlnotify
  def self.notify( title, message, icon = nil )

    # Put to the console also
    puts title, message

    # Setup parameters for growl
    params = ['-t', title, '-m', message]
    params |= ['-i', icon] if icon

    # Run growlnotify
    Kernel.system('growlnotify', *params)
  end
end

def projects_for_file( file )
  base_file = File.basename( file ).gsub(/\./, '\\.')
  regex = "Compile Include=\\\".*#{base_file}\\\""
  `grep -RHl --include "*.csproj" "#{regex}" *`.split
end

watch( '.*\.cs' ) do |cs|
  projects_for_file(cs[0]).each do |f|
    GrowlNotifier.notify 'Building Project', "Building #{f}"
    puts ( results = `xbuild /nologo /verbosity:quiet #{f}`.split("\n") )

    warnings = results.select{|r| r.include?('warning') }.length
    errors = results.select{|r| r.include?('error') }.length

    result = errors == 0 ? 'Successful' : 'Failed'

    GrowlNotifier.notify "Build #{result}", "Warnings: #{warnings}, Errors: 0"
  end
end

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  #run_all_tests
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }

GrowlNotifier.notify 'Watchr Loaded', 'System ready'
