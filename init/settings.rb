module Settings
  RES_X = 1400
  RES_Y = 1050
  FULLSCREEN = false

  DAMPING = 0.8
  SUBSTEPS = 6
  DT = 1 / 60.0

  FLAGS = {
    :needs_cursor       => true,
    :block_target_line  => false,
    :taxi_log           => false,
    :bubble_log         => false,
    :bubble_min_radius  => false,
    :bubble_radius      => true,
    :bubble_core_radius => false,
    :bubble_grow_radius => false
  }

  FLAGS.each do |flag, value|
    define_method("#{flag}?") { value }
  end

end
