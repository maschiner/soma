require 'gosu'
require_relative 'block.rb'

module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false
  SUBSTEPS = 6

  COLORS = {
    red: Gosu::red,
    green: Gosu::green,
    none: Gosu::white
  }

  DEBUG = {
    target_line: true,
    target_log: true
  }
end

class Numeric
  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end

class GameWindow < Gosu::Window
  attr_accessor :space

  def initialize
    super(Settings::RES_X, Settings::RES_Y, Settings::FULLSCREEN)
    self.caption = "soma alpha nil"

    @dt = (1.0/60.0)

    @space = CP::Space.new
    @space.damping = 0.9

    create_blocks(red: 20, green: 20)
  end

  def draw
    @blocks.each(&:draw)
  end

  def update
    Settings::SUBSTEPS.times do

      @blocks.each do |block|
        block.shape.body.reset_forces
        block.move
        block.validate_position
      end

      @blocks.first.accelerate if button_down? Gosu::KbUp
      @blocks.first.turn_left if button_down? Gosu::KbLeft
      @blocks.first.turn_right if button_down? Gosu::KbRight
      @blocks.first.target(mouse_x, mouse_y) if button_down? Gosu::MsLeft

      @space.step(@dt)
    end

  end

  def needs_cursor?
    true
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def create_blocks hash = {}
    @blocks = []
    hash.each do |color, count|
      count.times do

        body = CP::Body.new(10, 200)

        shape_array = [
          CP::Vec2.new(-16.0, -16.0),
          CP::Vec2.new(-16.0, 16.0),
          CP::Vec2.new(16.0, 16.0),
          CP::Vec2.new(16.0, -16.0)
        ]

        shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))

        @space.add_body(body)
        @space.add_shape(shape)

        @blocks << Block.new(self, shape, color: color)
      end
    end
    @blocks.each do |block|
      block.warp(CP::Vec2.new(rand(Settings::RES_X),rand(Settings::RES_Y)))
    end
  end

end

window = GameWindow.new
window.show