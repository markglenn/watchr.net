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
