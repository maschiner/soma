require 'rubygems'
require 'gosu'
require 'chingu'
require 'chipmunk'
require 'state_machine'
#require 'active_support'

require_relative "init/settings.rb"

Dir[File.join(".", "**/*.rb")].each { |file| require file }

include Gosu

class Soma < Chingu::Window
  include Settings

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)

    push_game_state(Menu)

    self.input = {
      esc: :exit
    }

  end

end

Soma.new.show
