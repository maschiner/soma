module TaxiController


  public

  def taxi_controller
    if taxi_change_mode_click?
      clicked_taxi.change_mode

    elsif bubble_click?
      observe_bubble_clicks

    else
      reset_first_bubble
    end
  end


  private

  attr_accessor :first_bubble


  # change_mode

  def taxi_change_mode_click?
    !!clicked_taxi
  end

  def clicked_taxi
    Taxi.all.select do |taxi|
      mouse_pos.inside?(taxi.click_target)
    end.first
  end


  # create / destroy

  def bubble_click?
    !!bubble_now
  end

  def bubble_now
    bubble_find(mouse_pos)
  end

  def bubble_find(vector)
    Bubble.all.select do |bubble|
      mouse_pos.inside?(bubble)
    end.first
  end

  def observe_bubble_clicks
    if second_bubble_click?

      if inverse_taxi
        inverse_taxi.die

      elsif !existing_taxi
        create_taxi(first_bubble, bubble_now)
      end

      reset_first_bubble

    else
      set_first_bubble
    end
  end

  def second_bubble_click?
    !!first_bubble && first_bubble != bubble_now
  end

  def inverse_taxi
    Taxi.all.select do |taxi|
      taxi.source_bubble == bubble_now &&
      taxi.target_bubble == first_bubble
    end.first
  end

  def existing_taxi
    Taxi.all.select do |t|
      t.source_bubble == first_bubble &&
      t.target_bubble == bubble_now
    end.first
  end

  def set_first_bubble
    @first_bubble = bubble_now
  end

  def reset_first_bubble
    @first_bubble = nil
  end

end