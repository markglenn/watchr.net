require_relative '../dotnet.watchr'

describe 'GrowlNotifier' do
  it "should execute growlnotify" do
    Kernel.should_receive( :system ).with(
      'growlnotify', '-t', 'title', '-m', 'message'
    )
    GrowlNotifier.notify 'title', 'message'
  end

  it "should growl with icon" do
    Kernel.should_receive( :system ).with(
      'growlnotify', '-t', 'title', '-m', 'message', '-i', 'icon.png'
    )
    GrowlNotifier.notify 'title', 'message', 'icon.png'
  end
end
