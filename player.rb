class Player

  attr_reader :x, :y
  def initialize(animation)
    @animation = animation
    @x = 8
    @y = 24
  end

  def move_up
    @y -= 2 if @y > 8
  end

  def move_down
    @y += 2 if @y < 240 - 8 - @animation[0].height
  end

  def draw
    img = @animation[Gosu::milliseconds / 150  % @animation.size]
    img.draw(@x, @y, ZOrder::Player)
  end

  def draw_fast
    img = @animation[Gosu::milliseconds / 50 % @animation.size]
    img.draw(@x, @y, ZOrder::Player)
  end

end
