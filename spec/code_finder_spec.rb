require_relative '../dotnet.watchr'

describe 'CodeFinder' do
  before( :each ) do
    @finder = CodeFinder.new( 'path/to/file.cs')
  end

  it 'should return matching project' do
    Dir.stub(:glob){['path/to/project.csproj']}

    @finder.project_file.should == 'path/to/project.csproj'
  end

  it 'should return best matching project' do
    Dir.stub(:glob){[
      'path/project.csproj',
      'path/to/project.csproj'
    ]}

    @finder.project_file.should == 'path/to/project.csproj'
  end

  it 'should return project in lower directory' do
    Dir.stub(:glob){['path/project.csproj']}
    @finder.project_file.should == 'path/project.csproj'
  end

  it 'should handle dll' do
    @finder = CodeFinder.new( 'path/to/bin/Debug/Project.dll')
    Dir.stub(:glob){[ 'path/to/Project.csproj' ]}
    @finder.project_file.should eq( 'path/to/Project.csproj' )
  end

  describe 'test_project' do
    before( :each ) do
    end

    it 'should return matching test project' do
      @finder.stub(:project_file){ 'path/Project.csproj'}
      Dir.should_receive(:glob).with('**/Project.Tests.csproj'){[]}
      @finder.test_project
    end
  end

  describe 'test_output' do
    it 'should return path to test dll' do
      @finder.stub(:test_project){ 'Project.Name.Tests/Project.Name.Tests.csproj' }
      @finder.test_output.should eq('Project.Name.Tests/bin/Debug/Project.Name.Tests.dll')
    end
  end
end
