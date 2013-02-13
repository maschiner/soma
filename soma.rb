require 'gosu'
#require 'chipmunk'
require_relative 'block.rb'

module Settings
  RES_X = 800
  RES_Y = 500

  COLORS = {
    red: 0xffff0000,
    green: 0xff00ff00,
    yellow: 0xffffff00,
    none: 0xffffffff
  }

  DEBUG = {
    target: false
  }

end

class GameWindow < Gosu::Window
  attr_accessor :space

  #SUBSTEPS = 10

  def initialize
    super(Settings::RES_X, Settings::RES_Y, false)
    self.caption = "soma"

    #@dt = (1.0/60.0)
    #@space = CP::Space.new

    #@space.gravity = CP::Vec2.new(0, 10)

    create_blocks(red: 6, green: 6)
  end

  def draw
    @blocks.each(&:draw)
  end

  def update
    @blocks.each(&:move)

    #SUBSTEPS.times do
      #@blocks.each do |b|
        # WE RESET THE FORCES BECAUSE THE WILL ACCUMULATE OVER THE SUBSTEPS OTHERWISE
        #b.shape.body.reset_forces
      #end
      #@space.step(@dt)
    #end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    @blocks.sample.target(mouse_x, mouse_y) if id == Gosu::MsLeft
  end

  def create_blocks hash = {}
    @blocks = []
    hash.each do |color, count|
      count.times do
        @blocks << Block.new(self, color: color)
      end
    end
  end

end

window = GameWindow.new
window.show