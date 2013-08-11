class Taxi < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  CLOCK = 5

  def initialize(options = {})
    super

    @source_bubble = options[:source_bubble]
    @target_bubble =  options[:target_bubble]
    @vacant = true

    #puts self.inspect
  end


  public

  attr_accessor :source_bubble, :target_bubble

  def draw
    begin
      $window.draw_line(
        *source_position, yellow,
        *target_position, yellow
      )
      draw_circle(*target_position, 20, yellow)

    rescue
    end


  end

  def run
    dispatch if ready?
    check_vacancy
  end


  private

  attr_accessor :block, :vacant

  def dispatch
    @block ||= source_bubble.deliver_block(target_position)
    if block
      vacant = false
      block.target = target_position
    end
  end

  def ready?
    vacant? &&
    Time.now.to_i % CLOCK == 0
  end

  def vacant?
    vacant
  end

  def check_vacancy
    if block && block.position.inside?(target_bubble)
      vacant = true
      @block = nil
    end
  end

  def source_position
    source_bubble.position
  end

  def target_position
    target_bubble.position
  end


end