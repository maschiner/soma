class Bubble < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  BASE_R = 50
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
    packed? ? grow : shrink
  end

  def kill
    destroy_taxis
    puts "#{time_now} bubl #{self.object_id} destroy" if log_bubble?
    destroy
  end

  def find_block(options = {}, taxi)
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
      if !is_target_bubble?
        if selected_blocks.one?
          taxi.source_bubble = nil
        elsif selected_blocks.empty?
          taxi.kill
        end
      end

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
