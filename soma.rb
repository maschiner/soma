require 'rubygems'
require 'gosu'
require 'chipmunk'

require_relative 'init.rb'
require_relative 'settings.rb'
require_relative 'colors.rb'
require_relative 'block.rb'

class GameWindow < Gosu::Window
  include Settings

  attr_reader :space, :blocks

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)
    self.caption = CAPTION

    setup_space

    create_blocks(white: 1, red: 100, green: 100)
  end

  def setup_space
    @space = CP::Space.new
    space.damping = DAMPING
  end

  def draw
    blocks.each(&:draw)
  end

  def update
    SUBSTEPS.times do

      blocks.each(&:move)
      listen_for_actions

      space.step(DT)
    end
  end

  def listen_for_actions
    if button_down? Gosu::KbUp
      blocks.first.accelerate
    end

    if button_down? Gosu::KbLeft
      blocks.first.turn_left
    end

    if button_down? Gosu::KbRight
      blocks.first.turn_right
    end

    if button_down? Gosu::MsLeft
      blocks.first.target = CP::Vec2.new(mouse_x, mouse_y)
    end

    if button_down? Gosu::KbEscape
      close
    end
  end

  def create_blocks(options={})
    @blocks = options.each_with_object([]) do |(color, count), blocks|
      count.times { blocks << Block.new(self, space, color: color) }
    end
  end

end

window = GameWindow.new
window.show