module Colors

  def method_missing(color_name)
    Gosu.send(color_name) if Gosu.respond_to?(color_name)
  end

end