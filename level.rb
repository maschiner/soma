class Level < Chingu::GameState
  include Settings
  include Colors

  attr_reader :space, :blocks

  def initialize(options = {})
    super

    @title = Chingu::Text.create(
      text: "Level #{options[:level]}",
      x: 20, y: 10, size: 30
    )

    setup_space

    create_blocks(white: 1, green: 50, red: 50)

    self.input = {
      r: -> { current_game_state.setup },
      mouse_left: -> { Block.all.first.target = mouse_pos }
    }
  end

  def update
    super

    $window.caption = "FPS: #{$window.fps} - GameObjects: #{game_objects.size}"

    SUBSTEPS.times do
      Block.each(&:move)
      space.step(DT)
    end
  end

  def setup
    Block.each do |block|
      block.stop
      block.position = center_pos
    end
  end

  def create_blocks(options={})
    options.each do |color, count|
      count.times do
        Block.create(
          space: space,
          spawn: center_pos,
          color: self.send(color)
        )
      end
    end
  end

  def setup_space
    @space = CP::Space.new
    space.damping = DAMPING
  end

end
