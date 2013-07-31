module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false
  SUBSTEPS = 6
  DT = 1/60.0

  CAPTION = "soma alpha nil"

  COLORS = {
    red: Gosu::red,
    green: Gosu::green,
    none: Gosu::white
  }

  DEBUG = {
    target_line: true,
    target_log: true
  }

  def needs_cursor?
    true
  end
end