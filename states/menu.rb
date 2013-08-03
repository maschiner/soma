class Menu < Chingu::GameState

  def initialize(options = {})
    super

    @title = Chingu::Text.create(
      text: "Press 'S' to Start game",
      x: 100,
      y: 50,
      size: 30
    )

    self.input = {
      s: Level.new(level: 1)
    }

  end

end
