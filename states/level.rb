class Level < Chingu::GameState
  include Helpers

  def initialize(options={})
    super
    setup_space

    render_title
    create_blocks(green: 3, red: 3)

    self.input = {
      :space  => :random_block_target,
      :mouse_left => :mouse_left,
      :mouse_right => :create_bubble,
      :r           => :restart,
      :t           => :create_taxi
    }
  end


  public

  def update
    super

    render_caption
    Bubble.each(&:run)
    Taxi.each(&:run)

    SUBSTEPS.times do
      Block.each(&:move)
      $space.step(DT)
    end

    #puts Taxi.all
  end

  def setup
    Block.each(&:reset)
    Bubble.destroy_all
    Taxi.destroy_all
  end


  private

  attr_accessor :last_bubble

  def mouse_left
    if bubble_now
      puts 'bubble now'

      if last_bubble
        puts 'bubble last'
        if inverse_taxi
          inverse_taxi.destroy
        else
          Taxi.create(
            source_bubble: last_bubble,
            target_bubble: bubble_now
          )
        end
        @last_bubble = nil
      else
        @last_bubble = bubble_now
      end

    end
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

  def create_taxi
    if Bubble.all.count >= 2

      bub1 = random_bubble
      bub2 = (Bubble.all - [bub1]).sample

      Taxi.create(
        source_bubble: bub1,
        target_bubble: bub2
      )
    end
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
