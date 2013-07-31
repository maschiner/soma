require 'chipmunk'

class Block
  attr_accessor :shape

  def initialize window, shape, options = {}
    @window = window

    @tarx = rand Settings::RES_X
    @tary = rand Settings::RES_Y

    @color = options[:color] || :none
    @image = Gosu::Image.new(window, 'media/block.png', false)

    @shape = shape
    @shape.body.p = CP::Vec2.new(0.0, 0.0)
    @shape.body.v = CP::Vec2.new(0.0, 0.0)
    @shape.body.a = (3*Math::PI/2.0)

    reset_target
  end

  def warp(vect)
    @shape.body.p = vect
  end

  def draw
    @image.draw_rot(
      @shape.body.p.x,
      @shape.body.p.y,
      10,
      @shape.body.a.radians_to_gosu,
      0.5, 0.5, 1, 1, Settings::COLORS[@color]
    )
    debug
  end

  def move
    if @tarx && @tary
      if Gosu::distance(@shape.body.p.x, @shape.body.p.y, @tarx, @tary) > 50
        @shape.body.a =
          Gosu::angle_diff(@shape.body.a, Gosu::angle(@shape.body.p.x, @shape.body.p.y, @tarx, @tary)) /
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
    @shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/Settings::SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
  end

  def turn_left
    @shape.body.t -= 400.0/Settings::SUBSTEPS
  end

  def turn_right
    @shape.body.t += 400.0/Settings::SUBSTEPS
  end

  def target x, y
    @tarx, @tary = x, y
  end

  def validate_position
    l_position = CP::Vec2.new(@shape.body.p.x % Settings::RES_X, @shape.body.p.y % Settings::RES_Y)
    @shape.body.p = l_position
  end

  def debug
    if Settings::DEBUG[:target_line]
      if @tarx && @tary
        if Gosu::distance(@shape.body.p.x, @shape.body.p.y, @tarx, @tary) > 50
          begin
            @window.draw_line(@shape.body.p.x, @shape.body.p.y, Gosu::white, @tarx, @tary, Gosu::white)
          rescue
            # draw_line crashes when x or y margins are within 2 pixels
          end
        end
      end
    end
  end

end