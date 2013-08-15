module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false

  DAMPING = 0.8
  SUBSTEPS = 6
  DT = 1 / 60.0

  def debug_block_target_line?
    false
  end

  def needs_cursor?
    true
  end

  def log_taxi?
    true
  end

  def log_bubble?
    true
  end

end