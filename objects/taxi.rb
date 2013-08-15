class Taxi < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers

  CLOCK = 5
  MODE_PAUSE = 2

  state_machine :transport_mode, :initial => :stop do
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
    @pause = 0

    puts "#{time_now} taxi #{self.object_id} new"
  end


  public

  attr_accessor :source_bubble, :target_bubble

  def change_mode
    toggle
    @pause = MODE_PAUSE
    puts "#{time_now} taxi #{self.object_id} change_mode #{self.transport_mode}"
  end

  def draw
    begin
      $window.draw_line(
        *source_position, mode_to_color,
        *target_position, mode_to_color
      )
      draw_circle(*source_position, 20, mode_to_color)
      draw_circle(*target_position, 5, mode_to_color)

    rescue
    end

  end

  def run
    if ready?
      if paused?
        puts "#{time_now} taxi #{self.object_id} paused" if log_taxi?
        decrement_pause
      else
        dispatch
      end
    end

    check_vacancy
  end

  def kill
    puts "#{time_now} taxi #{self.object_id} destroy" if log_taxi?
    self.destroy
  end


  private

  attr_accessor :block, :vacant, :pause

  def decrement_pause
    @pause -= 1
  end

  def mode_to_color
    {
      "stop" => blue,
      "both" => yellow,
      "green" => green,
      "red" => red
    }[transport_mode]
  end

  def dispatch
    @block ||= select_block

    if block
      puts "#{time_now} taxi #{self.object_id} dispatch block #{block.object_id}" if log_taxi?

      block.target = target_position
    end
  end

  def select_block
   if transport_mode == "green" || transport_mode == "red"
      source_bubble.find_block(near: target_position, color: transport_mode.to_sym)
    else
      source_bubble.find_block(near: target_position)
    end
  end

  def ready?
    running? && vacant?
  end

  def clock?
    Time.now.to_i % CLOCK * 3600 == 0
  end

  def running?
    transport_mode != "stop"
  end

  def paused?
    !unpaused?
  end

  def unpaused?
    pause.zero?
  end

  def vacant?
    block.nil?
  end

  def check_vacancy
    if block && block.position.inside?(target_bubble)
      vacant = true
      @block = nil
      puts "#{time_now} taxi #{self.object_id} ready" if log_taxi?
    end
  end

  def source_position
    source_bubble.position
  end

  def target_position
    target_bubble.position
  end


end