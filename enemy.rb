class Enemy

  attr_accessor :speed
  attr_reader :animation, :x, :y
  def initialize(animation)
    @animation = animation
    @x = 256 - @animation[0].width * 2
    @y = rand(240 - @animation[0].height * 2) + @animation[0].height
    @speed = 1.0
  end

  def move
    @x -= @speed
  end

  def draw
    img = @animation[Gosu::milliseconds / 1000 % @animation.size]
    img.draw(@x, @y, ZOrder::Enemy)
  end

end
