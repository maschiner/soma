class Block
  attr_accessor :x, :y, :tarx, :tary, :vel_x, :vel_y

  def initialize window, options = {}
    @window = window
    @x = @y = @vel_x = @vel_y = @angle = 0.0

    @x = rand Settings::RES_X
    @y = rand Settings::RES_Y
    @tarx = rand Settings::RES_X
    @tary = rand Settings::RES_Y

    @v = 0.1
    @v_r = 1
    @vr = @v_r * @v

    @color = options[:color] || :none
    @image = Gosu::Image.new(window, 'media/block.png', false)
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle, 0.5, 0.5, 1, 1, Settings::COLORS[@color])
    debug
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

  def accelerate
    @vel_x += Gosu::offset_x(@angle, @v)
    @vel_y += Gosu::offset_y(@angle, @v)
  end

  def target x, y
    @tarx, @tary = x, y

    if Settings::DEBUG[:target_log]
      puts "#{self} new target #{@tarx.to_i} #{@tary.to_i}"
    end
  end

  def debug
    if Settings::DEBUG[:target_line]
      if Gosu::distance(@x, @y, @tarx, @tary) > 50
        begin
          @window.draw_line(@x, @y, Gosu::white, @tarx, @tary, Gosu::white)
        rescue
          # draw_line crashes when x or y margins are within 2 pixels
        end
      end
    end
  end

end