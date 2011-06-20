# This class helps call growlnotify with the given parameters.
class GrowlNotifier

  # Executes growlnotify
  def self.notify( title, message, icon = nil )

    # Setup parameters for growl
    params = ['-t', title, '-m', message]
    params |= ['-i', icon] if icon

    # Run growlnotify
    Kernel.system('growlnotify', *params)
  end
end

class CodeFinder
  def initialize( file )
    @file = file
  end

  def project_file
    directory = File.dirname(@file)

    Dir.glob( '**/*.csproj' ).
      select{ |p| directory.include?(File.dirname(p)) }.
      sort_by{ |p| File.dirname(p).length }.
      last
  end

  def test_project
    project = File.basename(project_file,'.csproj')
    Dir.glob("**/#{project}.Tests.csproj").first
  end
end
