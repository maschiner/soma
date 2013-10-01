class Numeric

  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end

class CP::Vec2

  def inside?(circle, radius = nil)
    (self.x - circle.position.x) ** 2 +
    (self.y - circle.position.y) ** 2 <
    (radius || circle.radius) ** 2
  end

  def outside?(circle, radius = nil)
    !inside?(circle, radius)
  end
end