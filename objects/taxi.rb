class Taxi < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  CLOCK = 5

  # mode = Statemachine.build do
  #   trans :default, :toggle, :stop
  #   trans :stop, :toggle, :any
  #   trans :any, :toggle, :green
  #   trans :green, :toggle, :red
  #   trans :red, :toggle, :stop
  # end
 state_machine :transport_mode, :initial => :stop do
    # before_transition :parked => any - :parked, :do => :put_on_seatbelt

    # after_transition :on => :crash, :do => :tow
    # after_transition :on => :repair, :do => :fix
    # after_transition any => :parked do |vehicle, transition|
    #   vehicle.seatbelt_on = false
    # end

    state :stop, :both, :green, :red

    event :toggle do
      transition :stop => :both
      transition :both => :green
      transition :green => :red
      transition :red => :stop
    end

  end


  def initialize(options = {})
    super

    @source_bubble = options[:source_bubble]
    @target_bubble =  options[:target_bubble]
    @vacant = true
    #@mode = :stop

    puts transport_mode.inspect


  end


  public

  attr_accessor :source_bubble, :target_bubble#, :mode

  # def toggle
  #   puts transport_mode
  # end

  def change_mode
    toggle
    puts transport_mode
  end

  def draw
    begin
      $window.draw_line(
        *source_position, white,
        *target_position, white
      )
      draw_circle(*source_position, 20, mode_to_color)
      draw_circle(*target_position, 5, mode_to_color)

    rescue
    end

    # Chingu::Text.create(
    #   x: source_position.x, y: source_position.y, size: 30,
    #   text: "#{transport_mode}"
    # )
  end

  def run
    if mode != :stop
      dispatch if ready?
      check_vacancy
    end
  end


  private

  attr_accessor :block, :vacant

  def mode_to_color
    {
      "stop" => blue,
      "both" => yellow,
      "green" => green,
      "red" => red
    }[transport_mode]
  end

  def dispatch
    @block ||= if transport_mode == "green" || transport_mode == "red"
      source_bubble.deliver_block(target_position, color: transport_mode.to_sym)
    else
      source_bubble.deliver_block(target_position)
    end

    if block
      vacant = false
      block.target = target_position
    end
  end

  def ready?
    running? &&
    vacant? &&
    Time.now.to_i % CLOCK == 0
  end

  def running?
    transport_mode != "stop"
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