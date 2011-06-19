class GrowlNotifier
  def self.notify( title, message, icon = nil )
    if icon
      Kernel.system('growlnotify', '-t', title, '-m', message, '-i', icon)
    else
      Kernel.system('growlnotify', '-t', title, '-m', message)
    end
  end
end
