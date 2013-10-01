module Colors

  COLORS = %w(
    black
    white
    green
    red
    yellow
    blue
    fuchsia
    cyan
  )


  private

  COLORS.each do |color_name|
    define_method(color_name) do
      eval("@@#{color_name} ||= Gosu.#{color_name}")
    end
  end

end
