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

  describe 'test_project' do
    before( :each ) do
    end

    it 'should return matching test project' do
      @finder.stub(:project_file){ 'path/Project.csproj'}
      Dir.should_receive(:glob).with('**/Project.Tests.csproj'){[]}
      @finder.test_project
    end
  end
end
