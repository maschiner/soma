require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'block'
require 'floor'
include Gosu

class Game < Window
  PHYSICS_RESOLUTION = 50
  PHYSICS_TIME_DELTA = 1.0/350.0
  VISCOUS_DAMPING = 0.7
  GRAVITY = 30.0
  X_RES = 640
  Y_RES = 480

  def initialize
    super(X_RES, Y_RES, false)
    setup_gosu_and_chipmunk
    @blocks = []
    @floor = Floor.new(self, @space, 50, Y_RES - 50, 0, X_RES - 100)
  end

  def setup_gosu_and_chipmunk
    self.caption = "REALLY BORING!!!"
    @space = CP::Space.new
    @space.damping = VISCOUS_DAMPING
    @space.gravity = CP::Vec2.new(0,GRAVITY)
  end
  
  def update
    PHYSICS_RESOLUTION.times do |repeat|
      @space.step(PHYSICS_TIME_DELTA)
    end
  end
 
  def draw
    @blocks.each{|block| block.draw}
    @floor.draw
  end

  def more_blocks
    @blocks << Block.new(self, @space, X_RES/2.0 + (rand(100)/100.0), Y_RES - 400)
  end
  
  def button_down(id)
    if id == Button::KbEscape then close end
    if id == Button::KbSpace then more_blocks end
  end
end

Game.new.show
