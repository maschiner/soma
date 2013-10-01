class Level < Chingu::GameState
  include Helpers
  include TaxiController

  def initialize(options = {})
    super
    setup_space

    render_title

    self.input = {
      :mouse_left  => :mouse_left,
      :mouse_right => :mouse_right,
      :r           => :restart,
      :b           => :render_block_report,
      :m           => :faster,
      :n           => :slower,
      :c           => :toggle_color
    }

    @speed = 1
    @bg_color = black
    @draw_color = white
  end


  public

  def setup
    reset

    create_blocks(green: 12, red: 12)
    create_bubble(center_pos, 200, :register_blocks)
  end

  def update
    @speed.times do
      super

      render_caption

      #Taxi.each(&:step)
      #Bubble.each(&:step)

      SUBSTEPS.times do
        Block.each(&:move)
        $space.step(DT)
      end
    end
  end

  def draw
    super
    render_speed
    $window.draw_quad(
      0, 0, bg_color,
      RES_X, 0, bg_color,
      0, RES_Y, bg_color,
      RES_X, RES_Y, bg_color, -10
    )
  end


  private

  attr_reader :bg_color, :draw_color

  # input

  def mouse_left
    taxi_controller
  end

  def mouse_right
    create_bubble(mouse_pos, 80)
  end

  def restart
    current_game_state.setup
  end

  def faster
    if @speed.zero?
      @speed = 1
    else
      @speed *= 2
    end
  end

  def slower
    if @speed == 1
      @speed = 0
    else
      @speed /= 2
    end
  end

  def toggle_color
    @bg_color, @draw_color = @draw_color, @bg_color
    Bubble.each do |bubble|
      bubble.color = draw_color
    end

    @title.color = @speed_text.color = draw_color
  end


  # builders

  def create_blocks(options={})
    options.each do |color, count|
      count.times do
        Block.create(
          position: center_pos,
          angle: random_angle,
          color: self.send(color)
        )
      end
    end
  end

  def create_bubble(position, radius, options = nil)
    bubble = Bubble.create(
      position: position,
      radius: radius,
      color: draw_color
    )

    if options == :register_blocks
      Block.each do |block|
        bubble.add_block(block)
      end
    end
  end

  def create_taxi(source_bubble, target_bubble)
    Taxi.create(
      source_bubble: source_bubble,
      target_bubble: target_bubble
    )
  end


  # setup

  def setup_space
    $space = CP::Space.new
    $space.damping = DAMPING
  end

  def reset
    @first_bubble = nil
    Block.destroy_all
    Bubble.destroy_all
    Taxi.destroy_all
  end

  def render_block_report
    bubble_counts = Bubble.all.map(&:block_count)
    taxi_counts = Taxi.all.map(&:block_count)

    puts "block_report #{(bubble_counts.inject(0, &:+) + taxi_counts.inject(0, &:+))}
    #{bubble_counts.inspect} #{taxi_counts.inspect}"
  end

  def render_title
    @title = Chingu::Text.create(
      x: 20, y: 10, size: 30, color: draw_color,
      text: "R: Restart - B: Block report - N/M: Speed -/+"
    )
  end

  def render_speed
    @speed_text ||= Chingu::Text.create(
      x: RES_X - 100, y: 10, size: 30, color: draw_color,
      text: "x#{@speed}"
    )
    @speed_text.text = "x#{@speed}"
  end

  def render_caption
    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size}"
  end

end
