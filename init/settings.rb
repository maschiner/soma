module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false

  DAMPING = 0.99
  SUBSTEPS = 6
  DT = 1 / 60.0

  CAPTION = "soma alpha nil"

  DEBUG = {
    target_line: true
  }

  def needs_cursor?
    true
  end

  def mouse_pos
    CP::Vec2.new($window.mouse_x, $window.mouse_y)
  end

  def center_pos
    CP::Vec2.new(RES_X / 2, RES_Y / 2)
  end

  def random_pos
    CP::Vec2.new(rand(RES_X), rand(RES_Y))
  end

  def random_angle
    rand(2 * Math::PI)
  end
end