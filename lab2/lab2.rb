#electre 1
#http://rema44.ru/resurs/study/sppr/sppr06_RIPSA.pdf
#http://ofap.ulstu.ru/vt/tpr/lec06.html

criteria_weights = [5.0, 3.0, 2.0, 1.0]

agree_level = 0.5
disagree_level = 0.5

results_ranges = [100.0, 100.0, 100.0, 100.0]

names = %w{vanya sasha petya kolya}
results = [
  [100.0, 90.0,  80.0, 35.0],
  [90.0,  100.0, 50.0, 50.0],
  [70.0,  70.0,  70.0, 70.0],
  [50.0,  50.0,  50.0, 100.0]
]

agreement_criteria = results.map do |x|
  results.map do |y|
    (0...criteria_weights.count).reduce(0) do |sum, i|
      if x[i] >= y[i]
        sum + criteria_weights[i]
      else
        sum
      end
    end / criteria_weights.reduce(:+)
  end
end

p agreement_criteria

disagreemnt_criteria = results.map do |x|
  results.map do |y|
    (0...criteria_weights.count).map do |i|
      if y[i] > x[i]
        p 
        (y[i] - x[i]) / results_ranges[i]
      else
        0
      end
    end.max
  end
end

p disagreemnt_criteria

superiority = (0...results.count).map do |xi|
  (0...results.count).map do |yi|
    if agreement_criteria[xi][yi] > agree_level &&
       disagreemnt_criteria[xi][yi] < disagree_level
      1
    else
      0
    end
  end
end

p superiority
#delete weak results
res = superiority.transpose.each_with_index.select do | superiority_t, i|
  superiority_t.reduce(:+) == 1
end.map { |r, i| i}

p res.map {|i| names[i] }
