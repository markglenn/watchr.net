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

  # Project files should be built if changed
  return [file] if file =~ /\.(cs|vb)proj$/

  base_file = File.basename( file ).gsub(/\./, '\\.')
  regex = "Compile Include=\\\".*#{base_file}\\\""
  `grep -RHl --include "*.??proj" "#{regex}" *`.split
end

def test_project_for_project( project )
  base_file = File.basename( project, '.csproj' )
  Dir.glob("**/{base_file}.Tests.csproj").first
end

def build( project = nil )
  GrowlNotifier.notify 'Building', "Building #{project || 'Solution'}"
  puts ( results = `xbuild /nologo /verbosity:quiet #{project}`.split("\n") )

  warnings = results.select{|r| r.include?('warning') }.length
  errors = results.select{|r| r.include?('error') }.length

  result = ( errors == 0 ? 'Successful' : 'Failed' )

  GrowlNotifier.notify "Build #{result}", "Errors: #{errors}, Warnings: #{warnings}"
end

def test( project )
  project = test_project_for_project( project )

  if project
    GrowlNotifier.notify 'Running tests', "Testing #{project || 'Solution'}"

    puts ( results = `nunit-console4 -noshadow -nologo #{project}`.split("\n") )
  end

end

watch( '.*\.(cs|vb)(proj)?$' ) do |file|
  projects_for_file(file[0]).each{|f| build(f) }
end

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  build
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }
GrowlNotifier.notify 'Watchr Loaded', 'System ready'
