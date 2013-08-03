require 'rubygems'
require 'gosu'
require 'chingu'
require 'chipmunk'

Dir[File.join(".", "**/*.rb")].each { |file| require file }

include Gosu

class Soma < Chingu::Window
  include Settings

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)
    self.caption = CAPTION

    push_game_state(Menu)

    self.input = {
      esc: :exit
    }

  end

end

Soma.new.show
