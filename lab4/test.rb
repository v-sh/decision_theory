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

    @ball = Ball.new(320, 240, 400)
  end

  def update
    @ball.x_dir = 0
    @ball.y_dir = 0
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @ball.x_dir = -1
    end
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @ball.x_dir = +1
    end
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @ball.y_dir = -1
    end
    if button_down? Gosu::KbDown
      @ball.y_dir = 1
    end
    @ball.move
  end

  def draw
    p @ball
    img = Gosu::Image.new(self, Circle.new(@ball.radius.to_i), false)
    img.draw( @ball.x - @ball.radius / 2, @ball.y - @ball.radius / 2, 0)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show
