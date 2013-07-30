require 'chipmunk'

class Block
  #attr_accessor :x, :y, :tarx, :tary, :vel_x, :vel_y
  attr_accessor :shape

  def initialize window, shape, options = {}
    @window = window
    # @x = @y = @vel_x = @vel_y = @angle = 0.0

    # @x = rand Settings::RES_X
    # @y = rand Settings::RES_Y
    # @tarx = 320
    # @tary = 240

    # @v = 0.1
    # @v_r = 1
    # @vr = @v_r * @v

    @color = options[:color] || :none
    @image = Gosu::Image.new(window, 'media/block.png', false)

    @shape = shape
    @shape.body.p = CP::Vec2.new(0.0, 0.0) # position
    @shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
    @shape.body.a = (3*Math::PI/2.0)

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
    #@image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, Settings::COLORS[@color])
    #debug
  end

  # def move
  #   if Gosu::distance(@shape.body.p.x, @shape.body.p.y, @tarx, @tary) > 20
  #     @shape.body.a = Gosu::angle_diff(@shape.body.a, Gosu::angle(@shape.body.p.x, @shape.body.p.y, @tarx, @tary))
  #     accelerate
  #   end
  # end

  #  @x += @vel_x
  #  @y += @vel_y
  #  @x %= Settings::RES_X
  #  @y %= Settings::RES_Y

  #  @vel_x *= 0.95
  #  @vel_y *= 0.95
  # end

  def accelerate
    @shape.body.apply_force((@shape.body.a.radians_to_vec2 * (3000.0/Settings::SUBSTEPS)), CP::Vec2.new(0.0, 0.0))
  end

  def turn_left
    @shape.body.t -= 400.0/Settings::SUBSTEPS
  end

  def turn_right
    @shape.body.t += 400.0/Settings::SUBSTEPS
  end

  # def accelerate
  #   @vel_x += Gosu::offset_x(@angle, @v)
  #   @vel_y += Gosu::offset_y(@angle, @v)
  # end

  # def target x, y
  #   @tarx, @tary = x, y
  #   #move

  #   # if Settings::DEBUG[:target_log]
  #   #   puts "#{self} new target #{@tarx.to_i} #{@tary.to_i}"
  #   # end
  # end

  def validate_position
    l_position = CP::Vec2.new(@shape.body.p.x % Settings::RES_X, @shape.body.p.y % Settings::RES_Y)
    @shape.body.p = l_position
  end

  # def debug
  #   if Settings::DEBUG[:target_line]
  #     if Gosu::distance(@shape.body.p.x, @shape.body.p.y, @tarx, @tary) > 50
  #       begin
  #         @window.draw_line(@shape.body.p.x, @shape.body.p.y, Gosu::white, @tarx, @tary, Gosu::white)
  #       rescue
  #         # draw_line crashes when x or y margins are within 2 pixels
  #       end
  #     end
  #   end
  # end

end