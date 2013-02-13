require 'gosu'
require_relative 'block.rb'

module Settings
  RES_X = 1920
  RES_Y = 1200
  FULLSCREEN = true

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

class GameWindow < Gosu::Window
  attr_accessor :space

  def initialize
    super(Settings::RES_X, Settings::RES_Y, Settings::FULLSCREEN)
    self.caption = "soma alpha nil"

    create_blocks(red: 6, green: 6)
  end

  def draw
    @blocks.each(&:draw)
  end

  def update
    @blocks.each(&:move)
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