require 'gnuplot'
require 'gsl'
require 'pry'

EPS = 20
MIN_PTS = 2

g = GSL::Rng.alloc

class1 = (0...100).map do
  x = 100 + g.ugaussian(50)
  y = 100 + g.ugaussian(10) + 50 * Math.sin(x / 20)
  z = g.ugaussian(10) + 50 * Math.sin(x / 20)
  [x, y, z]
end

class2 = (0...100).map do
  x = g.ugaussian(10)
  y = g.ugaussian(50)
  z = g.ugaussian(10)
  [x, y, z]
end

class3 = (0...100).map do
  x = 150 + g.ugaussian(10)
  y = 100 + g.ugaussian(10)
  z = g.ugaussian(100)
  [x, y, z]
end

Gnuplot.open do |gp|
  Gnuplot::SPlot.new( gp ) do |plot|
  
    plot.title  "Array Plot Example"
    plot.xlabel "x"
    plot.ylabel "y"
    plot.zlabel 'z'
    
    x = (0..50).step(5).collect { |v| v.to_f }
    y = x.collect { |v| v ** 2 }
    z = x.map {|x| Math.sqrt x}
    
    plot.data << Gnuplot::DataSet.new( class1.transpose ) do |ds|
      ds.with = "points"
      ds.notitle
    end

    plot.data << Gnuplot::DataSet.new( class2.transpose ) do |ds|
      ds.with = "points"
      ds.notitle
    end

    plot.data << Gnuplot::DataSet.new( class3.transpose ) do |ds|
      ds.with = "points"
      ds.notitle
    end
  end
end

db = class1 + class2 + class3

class DBSCAN

  def initialize(db, eps, min_pts)
    @db = db
    @eps = eps
    @min_pts = min_pts
    @clusters = []
    @visited = Set.new
    @noise = []
  end

  def region_query(p)
    @db.select{|p1|
      p.zip(p1).map{|x,y| (x - y)**2 }.reduce(:+) ** 0.5 < @eps
    }
  end

  def dbscan
    while p = (@db.to_set - @visited).first
      #binding.pry
      @visited << p
      neighbours = region_query(p)
      if neighbours.count < @min_pts
        @noise << p
      else
        @clusters << []
        expand_cluster(p, neighbours, @clusters.last)
      end
    end
  
    [@clusters, @noise]
  end

  def expand_cluster(p, neighbours, cluster)
    cluster << p

    i = 0
    while i < neighbours.count
      p1 = neighbours[i]
      unless @visited.include? p1
        @visited << p1
        neighbours1 = region_query(p1)
        if neighbours1.count >= @min_pts
          neighbours += neighbours1.select{|x| ! neighbours.include?(x)}
        end
      end
      unless @clusters.find{|c| c.include? p1}
        cluster << p1
      end
      i += 1
    end
  end

end

dbscan = DBSCAN.new(db, EPS, MIN_PTS)
result, noise = dbscan.dbscan



Gnuplot.open do |gp|
  Gnuplot::SPlot.new( gp ) do |plot|
  
    plot.title  "Array Plot Example"
    plot.xlabel "x"
    plot.ylabel "y"
    plot.zlabel 'z'
    
    x = (0..50).step(5).collect { |v| v.to_f }
    y = x.collect { |v| v ** 2 }
    z = x.map {|x| Math.sqrt x}

    result.each do |c|
      plot.data << Gnuplot::DataSet.new( c.transpose ) do |ds|
        ds.with = "points"
        ds.notitle
      end
    end
  end
end
