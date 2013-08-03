class Bubble < Chingu::GameObject
  include Settings
  include Colors

  BASE_R = 100
  Z_INDEX = 5

  attr_reader :center, :color

  def initialize(options={})
    super
    @center = center
    @color = self.send(options[:color] || :white)

    puts self.inspect
  end

  def draw
    draw_circle(center.x, center.y, BASE_R, color, Z_INDEX)
  end

end