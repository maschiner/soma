class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  BASE_R = 250
  DEADLY_R = 20
  SHRINK_RATE = 1.0

  MASS = 10
  MOMENT = 1

  attr_reader :radius, :color

  def initialize(options={})
    super

    self.position = options[:position]
    @radius = options[:radius] || BASE_R
    @color = options[:color] || white

    register_to_space
  end

  public

  def draw
    draw_circle(*position, radius, color)
  end

  def run
    shrink
    destroy if collapsing?
    validate_position
  end

  private

  def validate_position
    position.x %= RES_X
    position.y %= RES_Y
  end

  def position=(vector)
    body.p = vector
  end

  def position
    body.p
  end

  def register_to_space
    $space.add_body(body)
    $space.add_shape(shape)
  end

  def body
    @body ||= CP::Body.new(MASS, MOMENT)

  end

  def shape
    CP::Shape::Circle.new(body, radius, zero_vector)
  end

  def shrink
    @radius -= SHRINK_RATE / SUBSTEPS
  end

  def collapsing?
    radius < DEADLY_R
  end

end
