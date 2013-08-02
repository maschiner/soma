module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false

  DAMPING = 1
  SUBSTEPS = 6
  DT = 1/60.0

  CAPTION = "soma alpha nil"

  DEBUG = {
    target_line: true
  }

  def needs_cursor?
    true
  end
end