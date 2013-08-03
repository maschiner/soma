module Helpers
  include Settings
  include Colors

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

  def zero_vector
    CP::Vec2.new(0, 0)
  end

end