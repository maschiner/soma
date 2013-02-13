class Block
  attr_accessor :x, :y, :tarx, :tary, :vel_x, :vel_y#, :shape

  BOX_SIZE = 10

  def initialize window, options = {}
    @window = window
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    #@shape = shape

    @x = rand Settings::RES_X
    @y = rand Settings::RES_Y
    @tarx = rand Settings::RES_X
    @tary = rand Settings::RES_Y

    @v = 0.1
    @v_r = 1
    @vr = @v_r * @v

    @color = Gosu::Color.new(Settings::COLORS[options[:color] || :none])
    @image = Gosu::Image.new(window, "media/block.png", false)

    # @body = CP::Body.new(10, 100)
    # @body.p = CP::Vec2.new(500, 500)
    # @body.v = CP::Vec2.new(0,0)
    # @body.a = (3 * Math::PI / 2.5)
    
    # @shape_verts = [
    #                 CP::Vec2.new(-BOX_SIZE, BOX_SIZE),
    #                 CP::Vec2.new(BOX_SIZE, BOX_SIZE),
    #                 CP::Vec2.new(BOX_SIZE, -BOX_SIZE),
    #                 CP::Vec2.new(-BOX_SIZE, -BOX_SIZE),
    #                ]

    # @shape = CP::Shape::Poly.new(@body,
    #                              @shape_verts,
    #                              CP::Vec2.new(0,0))
    
    # @shape.e = 0
    # @shape.u = 1 
    
    # WE ADD THE THE BODY AND SHAPE TO THE SPACE WHICH THEY WILL LIVE IN
    # @window.space.add_body(@body)
    # @window.space.add_shape(@shape)
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, @color)
    if Settings::DEBUG[:target]
      @window.draw_line(@x, @y, Gosu::white, @tarx, @tary, Gosu::white)
    end
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, @v)
    @vel_y += Gosu::offset_y(@angle, @v)
  end
  
  def move
   if Gosu::distance(@x, @y, @tarx, @tary) > 20
     @angle += @vr * Gosu::angle_diff(@angle, Gosu::angle(@x, @y, @tarx, @tary))
    accelerate
   end

   @x += @vel_x
   @y += @vel_y
   @x %= Settings::RES_X
   @y %= Settings::RES_Y
   
   @vel_x *= 0.95
   @vel_y *= 0.95
  end

  # def draw
  #   top_left, top_right, bottom_left, bottom_right = self.rotate
  #   @window.draw_quad(top_left.x, top_left.y, @color,
  #                     top_right.x, top_right.y, @color,
  #                     bottom_left.x, bottom_left.y, @color,
  #                     bottom_right.x, bottom_right.y, @color,
  #                     1)
  # end
  




  # def rotate
  
  #   half_diagonal = Math.sqrt(2) * (BOX_SIZE)
  #   [-45, +45, -135, +135].collect do |angle|
  #      CP::Vec2.new(@body.p.x + Gosu::offset_x(@body.a.radians_to_gosu + angle,
  #                                              half_diagonal),

  #                   @body.p.y + Gosu::offset_y(@body.a.radians_to_gosu + angle,
  #                                              half_diagonal))

  #   end
  # end












  def color?
    @color != :none
  end

  def target x, y
    @tarx, @tary = x, y
  end

end





































class Player
  attr_reader :score

  def initialize(window)
    @image = Gosu::Image.new(window, "media/Starfighter.bmp", false)
    @beep = Gosu::Sample.new(window, "media/Beep.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end
  
  def turn_left
    @angle -= 4.5
  end
  
  def turn_right
    @angle += 4.5
  end
  
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end
  
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 1920
    @y %= 1200
    
    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def score
    @score
  end

    def collect_stars(stars)
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 35 then
        @score += 10
        #@beep.play
        true
      else
        false
      end
    end
  end
end

class Star
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff000000)
    @color.red = rand(256 - 40) + 40
    @color.green = rand(256 - 40) + 40
    @color.blue = rand(256 - 40) + 40
    @x = rand * 640
    @y = rand * 480
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Stars, 1, 1, @color, :add)
  end
end