module Clocking
  include Settings

  CLOCK_BASE = 36_000
  CLOCK_FACTOR = (1 / DT) / 1000.0


  private

  def counter
    @counter ||= 0
  end

  def increment_counter
    @counter = (counter + 1) % CLOCK_BASE
  end

  def clock(interval = 1_000, &blk)
    yield if (counter % frames_from(interval)).zero?
  end

  def frames_from(interval)
    (interval * CLOCK_FACTOR).to_i
  end

end