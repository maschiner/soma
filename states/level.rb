class Level < Chingu::GameState
  include Helpers

  attr_reader :space, :blocks

  def initialize(options={})
    super

    @title = Chingu::Text.create(
      text: "Level #{options[:level]} - Press 'R' to restart",
      x: 20, y: 10, size: 30
    )

    setup_space

    create_blocks(white: 1, green: 50, red: 50)

    self.input = {
      r: -> { current_game_state.setup },
      mouse_left: -> { Block.all.first.target = mouse_pos },
      mouse_right: :create_bubble
    }
  end

  def update
    super

    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size}"

    SUBSTEPS.times do

      Block.each(&:move)
      Bubble.each(&:run)

      space.step(DT)
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
          space: space,
          position: center_pos,
          angle: random_angle,
          color: self.send(color)
        )
      end
    end
  end

  def create_bubble
    Bubble.create(
      space: space,
      center: mouse_pos
    )
  end

  def setup_space
    @space = CP::Space.new
    space.damping = DAMPING
  end

end
