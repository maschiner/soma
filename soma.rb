require 'rubygems'
require 'gosu'
require 'chingu'
require 'chipmunk'
require 'state_machine'
require 'active_support/all'

require_relative "init/settings.rb"

Dir[File.join(".", "**/*.rb")].each { |file| require file }

include Gosu

class Soma < Chingu::Window
  include Settings

  def initialize
    super(RES_X, RES_Y, FULLSCREEN)

    self.input = {esc: :exit}

    push_game_state(Menu)
  end

end

Soma.new.show
