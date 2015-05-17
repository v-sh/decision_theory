require 'gosu'
require 'pry'
require 'pry-nav'
require_relative 'game'


class Circle
  attr_reader :columns, :rows
  
  def initialize radius
    @columns = @rows = radius * 2
    lower_half = (0...radius).map do |y|
      x = Math.sqrt(radius**2 - y**2).round
      right_half = "#{"\xff" * x}#{"\x00" * (radius - x)}"
      "#{right_half.reverse}#{right_half}"
    end.join
    @blob = lower_half.reverse + lower_half
    @blob.gsub!(/./) { |alpha| "\xff\xff\xff#{alpha}"}
  end
  
  def to_blob
    @blob
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "like agar.io"

    @game = Game.new(100)
    50.times do
      @game.players << Killer.new(rand * MAX_X, rand * MAX_Y, rand * 10)
    end
    50.times do 
      @game.players << ShyKiller.new(rand * MAX_X, rand * MAX_Y, rand * 10)
    end
    50.times do 
      @game.players << GreedyShyKiller.new(rand * MAX_X, rand * MAX_Y, rand * 10)
    end
  end

  def update
    @game.play_move
  end

  def draw
    @game.active_players.each do |b|
      p b
      img = Gosu::Image.new(self, Circle.new(b.radius.to_i + 2), false)
      img.draw( b.x - b.radius / 2, b.y - b.radius / 2, 0, 1, 1, b.color)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show
