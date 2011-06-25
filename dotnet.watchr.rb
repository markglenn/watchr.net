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

class CodeFinder
  def initialize( file )
    @file = file
  end

  def project_file
    projects_for_file( @file ).first
  end

  def test_project
    project = File.basename(project_file,'.csproj')
    Dir.glob("**/#{project}.Tests.csproj").first
  end

  def test_output
    proj = test_project

    return nil if proj.nil?
    File.join( File.dirname(proj), 'bin', 'Debug', File.basename(proj, '.csproj') + '.dll' )
  end
end

GrowlNotifier.notify 'Watchr Loaded', 'System ready'

watch( '.*\.cs' ) do |cs|
  projects_for_file(cs[0]).each do |f|
    GrowlNotifier.notify 'Building Project', "Building #{f}"
    results = `xbuild /nologo /verbosity:quiet #{f}`.split("\n")

    puts results

    warnings = results.select{|r| r.include?('warning') }.length
    errors = results.select{|r| r.include?('error') }.length

    result = errors == 0 ? 'Successful' : 'Failed'

    GrowlNotifier.notify "Build #{result}", "Warnings: #{warnings}, Errors: 0"
  end
end

watch('.*/bin/.*dll11$') do |md|
  puts projects_for_file(md[0])
  return
  puts "#{md} changed"
  test_dll = CodeFinder.new( md[0] ).test_output

  if test_dll
    puts "Running tests in #{test_dll}"
    puts
    puts output = `nunit-console4 #{test_dll} -noshadow -nologo`

    /Tests run: (\d+), Failures: (\d+), Not run: (\d+)/.match(output) do |m|
      tests = m[1].to_i
      failures = m[2].to_i
      skipped = m[3].to_i

      if failures == 0
        GrowlNotifier.notify( 'Succeeded', 'All tests passed!' )
      else
        GrowlNotifier.notify( 'Failed', "#{failures} failures" )
      end
    end
  end
end
