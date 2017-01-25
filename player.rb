class Player

  attr_reader :x, :y
  def initialize(animation)
    @animation = animation
    @x = 8
    @y = 24
  end

  def move(dir)
    if dir == "up" && @y > 8
      @y -= 2
    end
    if dir == "down" && @y < 240 - 8 - @animation[0].height
      @y += 2
    end
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
