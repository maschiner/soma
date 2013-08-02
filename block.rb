class Block
  include Settings
  include Colors

  MASS = 10
  MOMENT = 100_000
  Z_INDEX = 1
  DRAW_SETTINGS = [0.5, 0.5, 1, 1]

  attr_reader :window, :color
  attr_accessor :target

  def initialize(window, space, options={})
    @window = window

    register_to(space)

    body.p = CP::Vec2.new(rand(RES_X), rand(RES_Y))
    body.v = CP::Vec2.new(0, 0)
    body.a = rand(2 * Math::PI)

    @image = Gosu::Image.new(window, 'media/block.png', false)
    @color = self.send(options[:color] || :white)
  end

  def body
    @body ||= shape.body
  end

  def register_to(space)
    space.add_body(body)
    space.add_shape(shape)
  end

  def shape
    @shape ||= CP::Shape::Poly.new(physical_body, shape_vectors, CP::Vec2.new(0,0))
  end

  def physical_body
    CP::Body.new(MASS, MOMENT)
  end

  def shape_vectors
    shape_array = [
      CP::Vec2.new(-16.0, -16.0),
      CP::Vec2.new(-16.0, 16.0),
      CP::Vec2.new(16.0, 16.0),
      CP::Vec2.new(16.0, -16.0)
    ]
  end

  def draw
    @image.draw_rot(
      body.p.x,
      body.p.y,
      Z_INDEX,
      body.a.radians_to_gosu,
      *DRAW_SETTINGS,
      color
    )
    debug
  end

  def move
    reset_forces
    move_to_target if target
    validate_position
  end

  def move_to_target
    if body.p.near?(target, 50)
      reset_target
    else
      turn_to(target)
      accelerate
    end
  end

  def turn_to(vect)
    body.a = (vect - body.p).to_angle
  end

  def reset_target
    @target = nil
  end

  def accelerate
    body.apply_force(
      body.a.radians_to_vec2 * 3000.0 / SUBSTEPS,
      CP::Vec2.new(0, 0)
    )
  end

  def turn_left
    body.t -= 400.0 / SUBSTEPS
  end

  def turn_right
    body.t += 400.0 / SUBSTEPS
  end

  def validate_position
    body.p.x %= RES_X
    body.p.y %= RES_Y
  end

  def reset_forces
    body.reset_forces
  end

  def debug
    if DEBUG[:target_line]
      if target && !body.p.near?(target, 50)
        begin
          window.draw_line(
            body.p.x, body.p.y, white,
            target.x, target.y, white
          )
        rescue
          # draw_line crashes when x or y margins are within 2 pixels
        end
      end
    end
  end

end