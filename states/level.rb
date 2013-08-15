class Level < Chingu::GameState
  include Helpers

  CLOCK_BASE = 3600

  def initialize(options={})
    super
    setup_space

    render_title
    create_blocks(green: 12, red: 12)

    self.input = {
      :space  => :random_block_target,
      :mouse_left => :mouse_left,
      :mouse_right => :create_bubble,
      :r           => :restart,
      :t           => :create_taxi
    }

    @counter = 0
  end


  public

  def update
    super

    increment_counter

    clock(3) do
      Taxi.each(&:run)
    end

    render_caption

    clock(1/15.0) do
      Bubble.each(&:run)
    end


    SUBSTEPS.times do
      Block.each(&:move)
      $space.step(DT)
    end
  end

  def setup
    Block.each(&:reset)
    Bubble.destroy_all
    Taxi.destroy_all
  end


  private

  attr_accessor :last_bubble, :counter

  def increment_counter
    @counter = (counter + 1) % CLOCK_BASE
  end

  def clock(seconds = 1, &blk)
    yield if counter % (seconds * 60).to_i == 0
  end



  def mouse_left
    if bubble_now
      if last_bubble

        if inverse_taxi
          inverse_taxi.kill

        elsif existing_taxi
          existing_taxi.change_mode

        else
          create_taxi(last_bubble, bubble_now)
        end

        @last_bubble = nil
      else
        @last_bubble = bubble_now
      end
    end
  end

  def create_taxi(source_bubble, target_bubble)
    Taxi.create(
      source_bubble: source_bubble,
      target_bubble: target_bubble
    )
  end

  def existing_taxi
    Taxi.all.select do |t|
      t.source_bubble == last_bubble &&
      t.target_bubble == bubble_now
    end.first
  end

  def inverse_taxi
    Taxi.all.select do |t|
      t.source_bubble == bubble_now &&
      t.target_bubble == last_bubble
    end.first
  end

  def bubble_now
    bubble_find(mouse_pos)
  end

  def bubble_find(vector)
    Bubble.all.select { |bubble| mouse_pos.inside?(bubble) }.first
  end

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

  def create_bubble
    Bubble.create(position: mouse_pos)
  end

  def random_bubble
    Bubble.all.sample
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
    $space.add_collision_func(:bubble, :block) { false }
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
