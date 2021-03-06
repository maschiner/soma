class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  BASE_R = 200
  DEADLY_R = 40

  SHRINK_RATE = 3.0
  SHRINK_MARGIN = 50

  GROW_RATE = 1.0
  GROW_MARGIN = 50

  MASS = 10
  MOMENT = 1

  def initialize(options={})
    super

    self.position = options[:position]
    @radius = options[:radius] || BASE_R
    @color = options[:color] || white

    @blocks = []

    register_blocks

    puts "#{time_now} bubl #{self.object_id} new" if log_bubble?
  end


  public

  attr_reader :radius

  def position
    body.p
  end

  def draw
    draw_circle(*position, radius, color)
  end

  def run
    kill if encased? || collapsing?
    remove_blocks
    add_blocks
    packed? ? grow : shrink
  end

  def kill
    destroy_taxis
    puts "#{time_now} bubl #{self.object_id} destroy" if log_bubble?
    destroy
  end

  def find_block(options = {})
    filtered_blocks = if options[:color]
      blocks.select { |b| b.color == self.send(options[:color]) }
    else
     blocks
    end

    if options[:near]
      filtered_blocks
        .select { |b| b.position.inside?(self) }
        .sort_by { |b| b.position.dist(options[:near]) }
        .first
    else
      filtered_blocks.first
    end
  end


  private

  attr_reader :color, :blocks


  # handle blocks

  def register_blocks
    Block.select { |block| block.position.inside?(self) }
      .each { |block| add_block(block) }
  end

  def add_blocks
    blocks_to_add.each { |block| add_block(block) }
  end

  def blocks_to_add
    Block.all.select do |block|
      block.target &&
      block.target.inside?(self)
    end - blocks
  end

  def add_block(block)
    @blocks << block
    block.target = position
  end

  def remove_blocks
    @blocks -= blocks_to_remove
  end

  def blocks_to_remove
    blocks.select { |block| block.target.outside?(self) }
  end


  # killing

  def encased?
    Bubble.all.any? do |bubble|
      bubble.position.inside?(self) &&
      bubble.radius > radius
    end
  end

  def collapsing?
    blocks.empty? && !is_target_bubble? && radius < DEADLY_R
  end

  def is_target_bubble?
    Taxi.all.any? { |t| t.target_bubble == self }
  end

  def destroy_taxis
    Taxi.all
      .select { |t| t.source_bubble == self }
      .each(&:kill)
  end


  # shrink/grow

  def packed?
    blocks.any? do |block|
      block.position.outside?(self, core_radius) &&
      block.position.inside?(self, grow_radius)
    end
  end

  def core_radius
    radius - SHRINK_MARGIN
  end

  def grow_radius
    radius + GROW_MARGIN
  end

  def shrink
    @radius -= SHRINK_RATE / SUBSTEPS if radius > DEADLY_R
  end

  def grow
    @radius += GROW_RATE / SUBSTEPS
  end


  # physics

  def position=(vector)
    body.p = vector
  end

  def body
    @body ||= CP::Body.new(MASS, MOMENT)
  end

end
