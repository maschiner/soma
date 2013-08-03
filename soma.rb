require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'chingu'

require_relative 'init.rb'
require_relative 'settings.rb'
require_relative 'colors.rb'
require_relative 'block.rb'
require_relative 'bubble.rb'
require_relative 'level.rb'

include Gosu

class Soma < Chingu::Window
  include Settings

  attr_reader :space, :blocks, :bubbles

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)
    self.caption = CAPTION

    push_game_state(Menu)

    self.input = {
      esc: :exit
    }

  end

end


class Menu < Chingu::GameState
  def initialize(options = {})
    super

    @title = Chingu::Text.create(
      text: "Press 'S' to Start game",
      x: 100, y: 50, size: 30
    )

    self.input = { s: Level.new(level: 1) }
  end
end


Soma.new.show
