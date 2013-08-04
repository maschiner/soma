class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  BASE_R = 200
  DEADLY_R = 20

  SHRINK_RATE = 3.0
  SHRINK_MARGIN = 50

  GROW_RATE = 2.0
  GROW_MARGIN = 50

  MASS = 10
  MOMENT = 1

  attr_reader :radius, :color, :blocks
  def initialize(options={})
    super

    self.position = options[:position]
    @radius = options[:radius] || BASE_R
    @color = options[:color] || white

    #register_to_space
    register_blocks

    #puts blocks.inspect
  end

  public

  def draw
    draw_circle(*position, radius, color)
  end

  def run
    packed? ? grow : shrink
    destroy if collapsing?
    destroy if encased?
    check_blocks
    validate_position
  end

  protected

  def position
    body.p
  end

  def inside?(vector, radius = self.radius)
    (vector.x - position.x) ** 2 +
    (vector.y - position.y) ** 2 < radius ** 2
  end

  private

  def packed?
    blocks.any? do |block|
      outside?(block.position, core_radius) &&
      inside?(block.position, grow_radius)
    end
  end

  def grow_radius
    radius + GROW_MARGIN
  end

  def encased?
    Bubble.all.any? do |bubble|
      bubble != self &&
      bubble.inside?(position) &&
      bubble.radius > radius
    end
  end

  def check_blocks
    @blocks -= blocks_to_remove
    blocks_to_add.each { |block| add_block(block) }
  end

  def add_block(block)
    @blocks << block
    block.target = position
  end

  def blocks_to_add
    Block.all.select do |block|
      block.target &&
      inside?(block.target) &&
      block.target != position
    end
  end

  def blocks_to_remove
    blocks.select do |block|
      outside?(block.target)
    end
  end

  def core_radius
    radius - SHRINK_MARGIN
  end

  def register_blocks
    @blocks = Block.select do |block|
      inside?(block.position)
    end

    blocks.each { |block| block.target = position }
  end

  def outside?(vector, radius = self.radius)
    !inside?(vector, radius)
  end

  def validate_position
    position.x %= RES_X
    position.y %= RES_Y
  end

  def position=(vector)
    body.p = vector
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

  def grow
    @radius += GROW_RATE / SUBSTEPS
  end

  def collapsing?
    radius < DEADLY_R && blocks.empty?
  end

end
