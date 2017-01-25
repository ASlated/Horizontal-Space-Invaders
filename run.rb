require 'gosu'
require './player.rb'
require './enemy.rb'

module ZOrder
  Background, Enemy, Laser, Player, UI = *0..4
end


class GameWindow < Gosu::Window

  WIDTH = 256
  HEIGHT = 240
  BLAST_CHARGING_TIME = 90
  TOTAL_LIVES = 20
  VOLUMES = {song: 0.1, explosion: 0.2, shoot: 0.05}

  def initialize
    super WIDTH, HEIGHT, true
    Gosu::enable_undocumented_retrofication
    @song = Gosu::Song.new("assets/sounds/music.mp3")
    @song.volume = VOLUMES[:song]
    @song.play(true)
    @explosion = Gosu::Sample.new("assets/sounds/explosion.mp3")
    @shoot = Gosu::Sample.new("assets/sounds/shoot.mp3")
    @player = Player.new(Gosu::Image::load_tiles("assets/images/ship.png", 20, 18))
    puts @player.inspect
    @enemies = []
    @enemies_speed = 1
    @alien_anim = Gosu::Image::load_tiles("assets/images/alien.png", 22, 16)
    @background = {x: 0, y: 0, img: Gosu::Image.new("assets/images/background.png")}
    @lasers = []
    @counter = 0
    @counter_limit = 10
    @blast_counter = 0
    @space_pressed = false
    puts @alien_anim.inspect
  end

  def lives
    @lives ||= TOTAL_LIVES.times.map do |life|
      Gosu::Image.new("assets/images/life.png")
    end
  end

  def die
    @lives.delete_at(-1)
  end

  def update
    if Gosu::button_down?(Gosu::KbQ)
      @player.move_up
    end
    if Gosu::button_down?(Gosu::KbA)
      @player.move_down
    end
    if Gosu::button_down?(Gosu::KbSpace)
      create_laser if !@space_pressed
      @space_pressed = true
    else
      if @space_pressed == true && @blast_counter >= BLAST_CHARGING_TIME
        create_laser(true)
      end
      @space_pressed = false
    end
    if @space_pressed
      @blast_counter += 1
    else
      @blast_counter = 0
    end
    @background[:x] -= 0.5
    @background[:y] = -(@player.y / 256.0) * (320 - 256)
    @lasers.each do |laser|
      laser[:x] += 5
      @enemies.each do |enemy|
        if Gosu::distance(laser[:x], laser[:y], enemy.x + enemy.animation[0].width / 2, enemy.y + enemy.animation[0].height / 2) < enemy.animation[0].height / 2
          @enemies.delete(enemy)
          @explosion.play(VOLUMES[:explosion])
        end
      end
    end
    @lasers.reject! { |laser| laser[:x] > 256 }
    @counter += 1
    if @counter == @counter_limit
      @enemies.push(Enemy.new(@alien_anim))
      @counter = 0
      @counter_limit = rand(10) + 30
      @enemies_speed += 0.003
    end
    @enemies.each { |enemy| enemy.speed = @enemies_speed }
    @enemies.each { |enemy| enemy.move }
    @enemies.each do |enemy|
      if enemy.x <= -enemy.animation[0].width
        die
        @enemies.delete(enemy)
      end
    end
    close if lives.empty?
  end

  def draw
    @lasers.each { |laser| laser[:img].draw(laser[:x], laser[:y], ZOrder::Laser) }
    lives.each_with_index do |life,index|
      life.draw((8 * index) + 8, 8, ZOrder::UI)
    end
    if @blast_counter >= BLAST_CHARGING_TIME
      @player.draw_fast
    else
      @player.draw
    end
    @enemies.each { |enemy| enemy.draw }
    local_x = @background[:x] % -@background[:img].width
    @background[:img].draw(local_x, @background[:y], 0)
    @background[:img].draw(local_x + @background[:img].width, @background[:y], 0) if local_x < (@background[:img].width - self.width)
  end

  def create_laser(blast = false)
    if blast
      @lasers.push({img:Gosu::Image.new("assets/images/laser.png"), x: @player.x, y: @player.y})
      blast_times = 8
      blast_times.times do |x|
        @lasers.push({img:Gosu::Image.new("assets/images/laser.png"), x: 8 * -x, y: @player.y - 8 * (x + 1)})
        @lasers.push({img:Gosu::Image.new("assets/images/laser.png"), x: 8 * -x, y: @player.y - 8 * -(x + 1)})
      end
    else
      @lasers.push({img: Gosu::Image.new("assets/images/laser.png"), x: @player.x + 12, y: @player.y + 8})
    end
    @shoot.play(VOLUMES[:shoot])
  end

end

window = GameWindow.new
window.show
