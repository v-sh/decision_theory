MAX_X = 640
MAX_Y = 480


class Ball
  attr_accessor :x, :y, :x_speed, :y_speed, :x_dir, :y_dir, :size

  def initialize(x, y, size)
    @x = x
    @y = y
    @size = size
    @x_dir = 1
    @y_dir = 0
    @x_speed = 0
    @y_speed = 0
  end

  def get_position
    [@x, @y]
  end
  
  def set_position(x, y)
    @x, @y = x, y
  end

  def max_speed
    10 / Math.log(size)
  end

  def speed
    (@x_speed ** 2 + @y_speed ** 2) ** 0.5
  end

  def acceleration_k
    max_speed * 0.01 
  end
  
  def resistance_k
    speed / max_speed * acceleration_k
  end

  def acceleration
    if @x_dir == 0 && @y_dir == 0
      [0, 0]
    else
      k = acceleration_k / (@x_dir ** 2 + @y_dir ** 2) ** 0.5
      [k * @x_dir, k * @y_dir]
    end
  end

  def resistance
    if speed == 0
      [0,0]
    else
      k = resistance_k / (@x_speed ** 2 + @y_speed ** 2) ** 0.5
      [k * @x_speed, k * @y_speed]
    end
  end

  def radius
    (size / Math::PI) ** 0.5
  end

  def move
    acc = self.acceleration
    resist = self.resistance
    (0..1).each do |i|
      acc[i] -= resist[i]
    end
    @x_speed += acc[0]
    @y_speed += acc[1]
    @x += @x_speed
    @y += @y_speed

    @x = [[0,@x].max, MAX_X].min 
    @y = [[0,@y].max, MAX_Y].min
  end

end

class Player < Ball

  def initialize(x, y, size)
    super
  end

  def think(players)
    self.x_dir = rand - 0.5
    self.y_dir = rand - 0.5
  end

  def color
    Gosu::Color::WHITE
  end
end

def distance(p1, p2)
  ((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2) ** 0.5
end

class Killer < Player

  def targets(players)
    players.select{|p| p.size < self.size}
  end

  def target(players)
    targets(players).min_by {|p| distance(self, p)}
  end

  def think(players)
    super
    nearest_feed = self.target(players)
    if nearest_feed
      self.x_dir, self.y_dir = [nearest_feed.x - self.x, nearest_feed.y - self.y]
    end
  end

  def color
    Gosu::Color::RED
  end
end

class ShyKiller < Killer

  def think(players)
    super
    nearest_enemy = players.select{|p| p.size > self.size}.min_by {|p| distance(self, p)}
    if nearest_enemy && distance(nearest_enemy, self) < 5 * nearest_enemy.radius
      self.x_dir, self.y_dir = [self.x - nearest_enemy.x, self.y - nearest_enemy.y]
    end
  end

  def color
    Gosu::Color::CYAN
  end
end

class GreedyShyKiller < ShyKiller

  def target(players)
    targets(players).sort_by{|x| distance(x, self)}[0..10].sort_by{|x| x.size}.last
  end

  def color
    Gosu::Color::YELLOW
  end

end

class Game
  attr_accessor :players
  def initialize(player_count)
    @players = (0...player_count).map do
      Player.new(rand * MAX_X,
                 rand * MAX_Y,
                 rand * 10)
    end
  end

  def play_move
    self.active_players.each{|p| p.think(self.active_players) }
    self.active_players.each(&:move)
    (0...players.count - 1).each do |p1i|
      (p1i+1...players.count).each do |p2i|
        p1 = @players[p1i]
        p2 = @players[p2i]
        if p1 && p2
          if p1.size >  p2.size && distance(p1, p2) < p1.radius
            @players[p2i] = nil
            p1.size += p2.size
          elsif p2.size > p1.size && distance(p1,p2) < p2.radius
            @players[p1i] = nil
            p2.size += p1.size
          end
        end
      end
    end
  end


  def active_players
    players.select{|x| x}
  end
end

