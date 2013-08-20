module Colors

  COLORS = %w(
    white
    green
    red
    yellow
    blue
  )

  COLORS.each do |color_name|
    define_method(color_name) do
      eval("@@#{color_name} ||= Gosu.#{color_name}")
    end
  end

end