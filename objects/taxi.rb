class Taxi < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers
  include Clocking

  MODE_PAUSE = 3
  SLOTS = 12

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
    @blocks = []

    puts "#{time_now} taxi #{self.object_id} new"
  end


  public

  attr_reader :target_bubble
  attr_accessor :source_bubble

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

  def step
    clock(1_000) { deliver if at_target? }

    if running?
      clock(1_000) { decrement_pause if paused? }
      clock(3_000) { dispatch if ready? }

      die if no_source?
    end

    increment_counter
  end

  def block_count
    blocks.count
  end

  def die
    unless empty?
      @source_position = blocks.last.position
    else
      kill
    end
  end

  def kill
    puts "#{time_now} taxi #{self.object_id} destroy" if log_taxi?
    self.destroy
  end


  private

  attr_accessor :blocks, :vacant, :pause
  attr_writer :target_bubble

  def no_source?
    source_bubble.nil?
  end

  def at_target?
    blocks.first && blocks.first.position.inside?(target_bubble)
  end

  def deliver
    target_bubble.add_block(@blocks.shift)
    puts "#{time_now} taxi #{self.object_id} delivered" if log_taxi?
  end


  # dispatch

  def dispatch
    block = select_block

    if block
      @blocks << block
      block.target = target_position

      puts "#{time_now} taxi #{self.object_id} dispatch block #{block.object_id}" if log_taxi?
    end
  end

  def select_block
    criteria = { near: target_position }
    criteria.merge!(color: transport_mode.to_sym) if color_filter?
    source_bubble.find_block(criteria, self)
  end


  # handle vacancy

  def ready?
    source_bubble && vacant? && unpaused?
  end

  def vacant?
    blocks.size < SLOTS
  end

  def empty?
    blocks.empty?
  end


  # pause

  def decrement_pause
    puts "#{time_now} taxi #{self.object_id} paused" if log_taxi?
    @pause -= 1
  end

  def paused?
    !unpaused?
  end

  def unpaused?
    pause.zero?
  end


  # positions

  def source_position
    @source_position ||= source_bubble.position
  end

  def target_position
    target_bubble.position
  end


  # state machine

  def running?
    transport_mode != "stop"
  end

  def color_filter?
    transport_mode == "green" ||
    transport_mode == "red"
  end

  def mode_to_color
    {
      "stop" => blue,
      "both" => yellow,
      "green" => green,
      "red" => red
    }[transport_mode]
  end

end