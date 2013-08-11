module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false

  DAMPING = 0.8
  SUBSTEPS = 6
  DT = 1 / 60.0

  DEBUG = {
    target_line: true
  }

  def needs_cursor?
    true
  end

end