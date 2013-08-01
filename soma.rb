require 'rubygems'
require 'gosu'
require 'chipmunk'

require_relative 'init.rb'
require_relative 'settings.rb'
require_relative 'colors.rb'
require_relative 'block.rb'

class GameWindow < Gosu::Window
  include Settings

  attr_reader :space

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)
    self.caption = CAPTION

    @space = CP::Space.new
    @space.damping = 1

    create_blocks(white: 1, red: 100, green: 100)
  end

  def draw
    @blocks.each(&:draw)
  end

  def update
    Settings::SUBSTEPS.times do

      @blocks.each do |block|
        block.reset_forces
        block.move
        block.validate_position
      end

      @blocks.first.accelerate if button_down? Gosu::KbUp
      @blocks.first.turn_left if button_down? Gosu::KbLeft
      @blocks.first.turn_right if button_down? Gosu::KbRight
      @blocks.first.target = CP::Vec2.new(mouse_x, mouse_y) if button_down? Gosu::MsLeft

      @space.step(DT)
    end

  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def create_blocks(options={})
    @blocks = options.each_with_object([]) do |(color, count), blocks|
      count.times do
        blocks << Block.new(self, space, color: color)
      end
    end
  end

end

window = GameWindow.new
window.show