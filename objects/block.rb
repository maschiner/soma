class Block  < Chingu::GameObject
  include Helpers

  MASS = 10
  MOMENT = 1000
  ELASTICITY = 0.5
  ACCELERATION = 100

  Z_INDEX = 10
  DRAW_SETTINGS = [0.5, 0.5, 1, 1]
  TARGET_RESET_DISTANCE = 30

  def initialize(options={})
    super
    @image = Image["block.png"]

    @initial_position = options[:position]
    @initial_angle    = options[:angle]

    register_to_space
    spawn
  end


  public

  attr_accessor :target
  attr_reader :image

  def move
    reset_forces
    move_to_target if target
    validate_position
  end

  def reset
    reset_velocity
    reset_rot_velocity
    reset_target

    spawn
  end

  def position
    body.p
  end

  def draw
    image.draw_rot(
      *position,
      Z_INDEX,
      angle.radians_to_gosu,
      *DRAW_SETTINGS,
      color
    )
    debug
  end

  def reset_velocity
    body.v = zero_vector
  end


  private

  attr_reader :color, :initial_position, :initial_angle

  def spawn
    self.position = initial_position
    self.angle = initial_angle
  end

  def register_to_space
    $space.add_body(body)
    $space.add_shape(shape)
  end

  def body
    @body ||= CP::Body.new(MASS, MOMENT)
  end

  def shape
    @shape ||= create_shape
  end

  def create_shape
    shape = CP::Shape::Poly.new(
      body,
      shape_vectors,
      zero_vector
    )
    shape.e = ELASTICITY
    shape.collision_type = :block
    shape
  end

  def shape_vectors
    [
      CP::Vec2.new( 16.0,  16.0),
      CP::Vec2.new( 16.0, -16.0),
      CP::Vec2.new(-16.0, -16.0),
      CP::Vec2.new(-16.0,  16.0)
    ]
  end

  def position=(vector)
    body.p = vector
  end

  def angle=(radians)
    body.a = radians
  end

  def angle
    body.a
  end

  def lock_to_target
    turn_to(target)
    accelerate
  end

  def move_to_target
    if position.near?(target, TARGET_RESET_DISTANCE)
      #reset_target
    else
      lock_to_target
    end
  end

  def turn_to(vector)
    self.angle = (vector - position).to_angle
  end

  def accelerate
    body.apply_force(
      acceleration_vector,
      zero_vector
    )
  end

  def acceleration_vector
    angle.radians_to_vec2 * ACCELERATION / SUBSTEPS
  end

  def validate_position
    position.x %= RES_X
    position.y %= RES_Y
  end

  def reset_forces
    body.reset_forces
  end

  def reset_rot_velocity
    body.w = 0
  end

  def reset_target
    @target = nil
  end

  def debug
    if DEBUG[:target_line]
      if target && !body.p.near?(target, TARGET_RESET_DISTANCE)
        begin
          $window.draw_line(*position, white, *target, white)
        rescue
          # draw_line crashes when x or y margins are within 2 pixels
        end
      end
    end
  end

end