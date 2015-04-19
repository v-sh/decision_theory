require 'gsl'
require "gnuplot"
require 'heatmap'

R1 = - 10
R2 = 100

K1 = 1
K2 = 1000

def func(x,y)
  -200 / (x-R1).abs - 100 / (x-R2).abs + K1 * y + K2 ** Math.exp(-y) 
end

def func_with_restrictions(x,y)
  func(x,y) + 10000 * (1.0/ (x - R1).abs + 1.0 / (R2 - x).abs + 1.0/ y.abs)
end

include GSL::MultiMin

np = 2

my_f = Proc.new { |v, params|
  x = v[0]; y = v[1]
  func_with_restrictions(x,y)
}

my_func = Function.alloc(my_f, np)

x = GSL::Vector.alloc [50, 20]
ss = GSL::Vector.alloc(np)
ss.set_all(1.0)

minimizer = FMinimizer.alloc("nmsimplex", np)
minimizer.set(my_func, x, ss)

iter = 0
begin
  iter += 1
  status = minimizer.iterate()
  status = minimizer.test_size(1e-5)
  if status == GSL::SUCCESS
    puts("converged to minimum at")
  end
  x = minimizer.x
  printf("%5d ", iter);
  for i in 0...np do
    printf("%10.3e ", x[i])
  end
  printf("f() = %7.3f size = %.3f\n", minimizer.fval, minimizer.size);
end while status == GSL::CONTINUE and iter < 100


require 'gimuby'
require 'gimuby/genetic/solution/function_based_solution'

class SampleProblemSolution < FunctionBasedSolution

  def evaluate
    func_with_restrictions(*@x_values)
  end

  protected

  def get_x_value_min
    1
  end

  def get_x_value_max
    99
  end

  def get_dimension_number
    2
  end
end

factory = Gimuby.get_factory
factory.optimal_population = TRUE
optimizer = factory.get_population {next SampleProblemSolution.new}

200.times do
  optimizer.generation_step
end

puts optimizer.get_best_solution.get_solution_representation
puts optimizer.get_best_fitness
