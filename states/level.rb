class Level < Chingu::GameState
  include Helpers

  def initialize(options={})
    super
    setup_space

    render_title
    create_blocks(green: 20, red: 20)

    self.input = {
      :r => :restart,
      :mouse_left => :random_block_target,
      :mouse_right => :create_bubble
    }
  end

  def update
    super

    render_caption
    Bubble.each(&:run)

    SUBSTEPS.times do

      Block.each(&:move)
      $space.step(DT)
    end
  end

  def setup
    Block.each(&:reset)
    Bubble.destroy_all
  end

  def create_blocks(options={})
    options.each do |color, count|
      count.times do
        Block.create(
          position: random_pos,
          angle: random_angle,
          color: self.send(color)
        )
      end
    end
  end

  def create_bubble
    Bubble.create(position: mouse_pos)
  end

  def random_block_target
    Block.all.sample.target = mouse_pos
  end

  def restart
    current_game_state.setup
  end

  def setup_space
    $space = CP::Space.new
    $space.damping = DAMPING
  end

  def render_title
    @title = Chingu::Text.create(
      x: 20, y: 10, size: 30,
      text: "Level #{options[:level]} - Press 'R' to restart"
    )
  end

  def render_caption
    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size}"
  end

end
