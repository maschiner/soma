class Block  < Chingu::GameObject
  include Settings
  include Colors

  MASS = 10
  MOMENT = 100_000

  Z_INDEX = 10
  DRAW_SETTINGS = [0.5, 0.5, 1, 1]
  TARGET_RESET_DISTANCE = 50

  attr_accessor :target
  attr_reader :image, :color

  def initialize(options={})
    super
    @image = Image["block.png"]

    register_to(options[:space])

    position = options[:position]
    body.a = random_angle
  end

  def register_to(space)
    space.add_body(body)
    space.add_shape(shape)
  end

  def body
    @body ||= shape.body
  end

  def shape
    @shape ||= CP::Shape::Poly.new(
      physical_body,
      shape_vectors,
      CP::Vec2.new(0,0)
    )
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

  def position=(vect)
    body.p = vect
  end

  def draw
    image.draw_rot(
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
    if body.p.near?(target, TARGET_RESET_DISTANCE)
      reset_target
    else
      turn_to(target)
      accelerate
    end
  end

  def turn_to(vect)
    body.a = (vect - body.p).to_angle
  end


  def accelerate
    body.apply_force(
      body.a.radians_to_vec2 * 3000.0 / SUBSTEPS,
      CP::Vec2.new(0, 0)
    )
  end

  def validate_position
    body.p.x %= RES_X
    body.p.y %= RES_Y
  end

  def reset
    reset_forces
    reset_velocity
    reset_target
  end

  def reset_forces
    body.reset_forces
  end

  def reset_velocity
    body.v = CP::Vec2.new(0, 0)
  end

  def reset_target
    @target = nil
  end

  def debug
    if DEBUG[:target_line]
      if target && !body.p.near?(target, TARGET_RESET_DISTANCE)
        begin
          $window.draw_line(
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