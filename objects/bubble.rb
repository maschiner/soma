class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  BASE_R = 250
  DEADLY_R = 20
  SHRINK_RATE = 1.0

  attr_reader :center, :radius, :color

  def initialize(options={})
    super

    @center = options[:center]
    @radius = options[:radius] || BASE_R
    @color  = options[:color] || white
  end

  public

  def draw
    draw_circle(*center, radius, color)
  end

  def run
    shrink
    destroy if collapsing?
  end

  private

  def shrink
    @radius -= SHRINK_RATE / SUBSTEPS
  end

  def collapsing?
    radius < DEADLY_R
  end

end
