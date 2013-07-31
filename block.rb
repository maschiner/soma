class Block
  include Settings

  def initialize(window, space, options={})
    @window = window

    self.register_to(space)

    body.p = CP::Vec2.new(0.0, 0.0)
    body.v = CP::Vec2.new(0.0, 0.0)
    body.a = (3*Math::PI/2.0)

    @tarx = rand Settings::RES_X
    @tary = rand Settings::RES_Y

    @color = options[:color] || :none
    @image = Gosu::Image.new(window, 'media/block.png', false)

    self.warp(CP::Vec2.new(rand(RES_X),rand(RES_Y)))

    reset_target
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
    CP::Body.new(10, 200)
  end

  def shape_vectors
    shape_array = [
      CP::Vec2.new(-16.0, -16.0),
      CP::Vec2.new(-16.0, 16.0),
      CP::Vec2.new(16.0, 16.0),
      CP::Vec2.new(16.0, -16.0)
    ]
  end

  def warp(vect)
    body.p = vect
  end

  def draw
    @image.draw_rot(
      body.p.x,
      body.p.y,
      10,
      body.a.radians_to_gosu,
      0.5, 0.5, 1, 1, Settings::COLORS[@color]
    )
    debug
  end

  def move
    if @tarx && @tary
      if Gosu::distance(body.p.x, body.p.y, @tarx, @tary) > 50
        body.a =
          Gosu::angle_diff(body.a, Gosu::angle(body.p.x, body.p.y, @tarx, @tary)) /
          Settings::SUBSTEPS
        accelerate
      else
        reset_target
      end
    end
  end

  def reset_target
    @tarx = @tary = nil
  end

  def accelerate
    body.apply_force((body.a.radians_to_vec2 * (3000.0/Settings::SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
  end

  def turn_left
    body.t -= 400.0/Settings::SUBSTEPS
  end

  def turn_right
    body.t += 400.0/Settings::SUBSTEPS
  end

  def target x, y
    @tarx, @tary = x, y
  end

  def validate_position
    l_position = CP::Vec2.new(body.p.x % Settings::RES_X, body.p.y % Settings::RES_Y)
    body.p = l_position
  end

  def reset_forces
    body.reset_forces
  end

  def debug
    if Settings::DEBUG[:target_line]
      if @tarx && @tary
        if Gosu::distance(body.p.x, body.p.y, @tarx, @tary) > 50
          begin
            @window.draw_line(body.p.x, body.p.y, Gosu::white, @tarx, @tary, Gosu::white)
          rescue
            # draw_line crashes when x or y margins are within 2 pixels
          end
        end
      end
    end
  end

end