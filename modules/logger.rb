module Logging

  def log(message, comment = nil)
    puts "#{time_now} #{short_name} #{short_id} #{message} #{comment}" if self.send("#{self.class.name.downcase}_log?")
  end

  def time_now
    Time.now.strftime('%S')
  end

  def short_name
    self.class.name.downcase[0, 4]
  end

  def short_id
    self.object_id.to_s[6, 4]
  end

end