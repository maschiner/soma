class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers
  include Clocking
  include Logging

  BASE_R = 60
  MIN_R  = 60

  FREE_MARGIN = 60
  CORE_MARGIN = 50
  GROW_MARGIN = 0

  SHRINK_RATE = 2.0
  GROW_RATE = 1.0

  MASS = 10
  MOMENT = 1

  def initialize(options={})
    super

    self.position = options[:position]
    @radius = options[:radius] || BASE_R
    @color = options[:color] || black

    @blocks = []
    @taxis = []

    log(:new)
  end


  public

  attr_reader :radius

  def position
    body.p
  end

  def draw
    draw_circle(*position, core_radius, cyan) if bubble_core_radius?
    draw_circle(*position, grow_radius, cyan) if bubble_grow_radius?
    draw_circle(*position, radius, color) if bubble_radius?
    draw_circle(*position, MIN_R, fuchsia) if bubble_min_radius?
  end

  def update

    kill if finished? && shrunk?

    if packed?
      grow
    elsif too_big?
      shrink
    else
      #free_blocks
    end

    clock(1_000) do
      blocks.select do |block|
        block.position.inside?(self, core_radius)
      end.each(&:hold)
    end

    # clock(5_000) do
    #   compress_blocks
    # end

    check_orders

    increment_counter
  end

  def kill
    destroy_taxis
    log(:destroy)
    destroy
  end

  def register(taxi)
    @taxis << taxi
  end

  def check_orders
    taxis.each do |taxi|
      block = find_block(taxi.block_criteria)

      if block
        #taxi.target_bubble.add_block(block)
        taxi.add_block(block)
        taxis.delete(taxi)
      elsif !is_target_bubble?
        taxi.die
        taxis.delete(taxi)
      end
    end
  end

  def find_block(options = {})
    filtered_blocks = if options[:color]
      blocks.select { |b| b.color == self.send(options[:color]) }
    else
     blocks
    end

    selected_blocks = if options[:near]
      filtered_blocks
        .select { |b| b.position.inside?(self) }
        .sort_by { |b| b.position.dist(options[:near]) }
    else
      filtered_blocks
    end

    if selected_blocks
      @blocks -= [selected_blocks.first]
      return selected_blocks.first
    end
  end

  def add_block(block)
    @blocks << block
    block.target = position
  end

    def block_count
    blocks.count
  end


  private

  attr_reader :color, :blocks
  attr_accessor :taxis

  def shrunk?
    radius < MIN_R + 1
  end

  def compress_blocks
    blocks.each { |block| block.target = position }
  end

  def free_blocks
    blocks
      .select { |block| block.position.inside?(self, free_radius) }
      .each { |block| block.target = nil }
  end

  def free_radius
    radius - FREE_MARGIN
  end

  def too_big?
    radius > MIN_R
  end


  # killing

  def finished?
    empty? && !is_target_bubble?
  end

  def empty?
    blocks.empty?
  end

  def is_target_bubble?
    Taxi.all.any? { |t| t.target_bubble == self }
  end

  def destroy_taxis
    Taxi.all
      .select { |t| t.source_bubble == self }
      .each { |taxi| taxi.source_bubble = nil }
  end


  # shrink/grow

  def packed?
    blocks.any? do |block|
      block.position.outside?(self, core_radius) &&
      block.position.inside?(self, grow_radius)
    end
  end

  def core_radius
    radius - CORE_MARGIN
  end

  def grow_radius
    radius + GROW_MARGIN
  end

  def shrink
    @radius -= SHRINK_RATE / SUBSTEPS
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
