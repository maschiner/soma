class Taxi < Chingu::GameObject
  include Chingu::Helpers::GFX
  include Helpers
  include Clocking
  include Logging

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

  attr_reader :target_bubble
  attr_accessor :source_bubble

  def initialize(options = {})
    super

    @source_bubble = options[:source_bubble]
    @target_bubble =  options[:target_bubble]
    @vacant = true
    @pause = 0
    @blocks = []

    log(:new)
  end


  public

  def update
    die if no_source? || dying?

    clock(100) do
      deliver
    end # if at_target? }

    if running?
      clock(1_000) { decrement_pause if paused? }
      clock(2_000) { dispatch if ready? }
    end

    increment_counter
  end

  def change_mode
    @pause = MODE_PAUSE
    toggle
    log(:mode, self.transport_mode)
  end

  def draw
    begin
      $window.draw_line(
        *source_position, mode_to_color,
        *target_position, mode_to_color
      )
      #draw_circle(*source_position, 30, mode_to_color)
      #draw_circle(*target_position, 10, mode_to_color)

      draw_circle(*middle_position, 20, mode_to_color) unless dying?

    rescue
    end
  end

  def click_target
    @click_target ||= Struct.new(:position, :radius).new(middle_position, 20)
  end

  def middle_position
    @middle_position ||= CP::Vec2.new(middle(:x), middle(:y))
  end

  def middle(axis)
    s = source_position.send(axis)
    t = target_position.send(axis)

    if s < t
      small = s
      half = (t - s) / 2
      return (small + half).to_i

    elsif s > t
      small = t
      half = (s - t) / 2
      return (small + half).to_i

    else
      return s
    end
  end

  def done
    @waiting = false
  end

  def block_count
    blocks.count
  end

  def die
    stop!

    if empty?
      kill
    else
      @dying ||= true
      @source_position = blocks.last.position
    end
  end

  def kill
    log(:destroy)
    #puts "#{time_now} taxi #{self.object_id} destroy" if log_taxi?
    self.destroy
  end

  def block_criteria
    criteria = { near: target_position }
    criteria.merge!(color: transport_mode.to_sym) if color_filter?
    criteria
  end

  def add_block(block)
    @waiting = false
    @blocks << block
    block.target = target_position
    block.travel

    log(:dispatch, block.object_id)
  end


  private

  attr_accessor :blocks, :vacant, :pause, :dying, :waiting
  attr_writer :target_bubble

  def dying?
    dying
  end

  def waiting?
    waiting
  end

  def no_source?
    source_bubble.nil?
  end

  def at_target?
    blocks.first && blocks.first.position.inside?(target_bubble)
  end

  def deliver
    #log('deliver()')
    btd = blocks_to_deliver

    if !btd.empty?
      #log(btd.inspect)

      btd.each do |block|
        target_bubble.add_block(block)
        @blocks.delete(block)

        log(:delivered)
      end

    end
  end

  def blocks_to_deliver
    blocks.select { |block| block.position.inside?(target_bubble) }
  end


  # dispatch

  def dispatch
    request_block
    @waiting = true
  end

  def request_block
    source_bubble.register(self)
  end




  # handle vacancy

  def ready?
    source_bubble && vacant? && unpaused? && !dying? && !waiting?
  end

  def vacant?
    blocks.size < SLOTS
  end

  def empty?
    blocks.empty?
  end


  # pause

  def decrement_pause
    log(:paused)
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

  def stop!
    @transport_mode = "stop"
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
