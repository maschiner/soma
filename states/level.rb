class Level < Chingu::GameState
  include Helpers
  include Clocking

  def initialize(options={})
    super
    setup_space

    render_title
    create_blocks(green: 6, red: 6)

    self.input = {
      :mouse_left  => :taxi_input,
      :mouse_right => :create_bubble,
      :space       => :random_block_target,
      :r           => :restart,
      :t           => :create_taxi
    }
  end


  public

  def update
    super

    render_caption

    clock(5_000) do
      bubble_counts = Bubble.all.map(&:block_count)
      taxi_counts = Taxi.all.map(&:block_count)

      puts (bubble_counts.inject(0, &:+) + taxi_counts.inject(0, &:+)).to_s +
      " " + bubble_counts.inspect + " " + taxi_counts.inspect
    end

    increment_counter

    Taxi.each(&:step)
    Bubble.each(&:run)

    SUBSTEPS.times do
      Block.each(&:move)
      $space.step(DT)
    end
  end

  def setup
    Block.each(&:reset)
    Bubble.destroy_all
    Taxi.destroy_all

    bubble = Bubble.create(
      position: center_pos,
      radius: 100
    )
    Block.each { |block| bubble.add_block(block) }
  end


  private

  attr_accessor :last_bubble


  # input

  def taxi_input
    if bubble_now && bubble_now != last_bubble
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

  def random_block_target
    Block.all.sample.target = mouse_pos
  end

  def restart
    current_game_state.setup
  end


  # taxi input

  def bubble_now
    bubble_find(mouse_pos)
  end

  def bubble_find(vector)
    Bubble.all.select { |bubble| mouse_pos.inside?(bubble) }.first
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

  def create_bubble
    Bubble.create(position: mouse_pos)
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
