# Rhys Williams (661561)
# 19/03/15
# SWEN30006 Software Modelling and Design
# Project 1
#
# This program is used to determine the best equation to model the given datapoints
# using the specified regression type.  The program is invoked from the command line
# using the command 'ruby ./661561-project-one.rb <input_file> <regression_type>'
# the program prints the best possible equation and exits.
#
# Acknowledgements:
# statsample: http://ruby-statsample.rubyforge.org/

require 'csv'
require 'set'
require 'statsample'

#Constants
LINEAR = "linear"
POLYNOMIAL = "polynomial"
EXPONENTIAL = "exponential"
LOGARITHMIC = "logarithmic"
BEST_FIT = "best_fit"

VALID_REGRESSIONS = Set[LINEAR, POLYNOMIAL, EXPONENTIAL, LOGARITHMIC, BEST_FIT]

# Error constants
DOMAIN_ERROR = 1
FILE_PATH = 2
ARGUMENT_ERROR = 3


# Read in given arguments, checking for their validity and returning the filename
# and regression type to the calling function.
def read_arguments
	if (ARGV.length() < 2)
		raise ArgumentError, "Invalid number of arguments, \n correct usage 'ruby ./661561-project-one.rb <input_file> <regression_type>'"
	end
	
	filename = ARGV[0]
	regression_type = ARGV[1]

	if !(VALID_REGRESSIONS.include? regression_type)
		raise ArgumentError, 'Regression type is not valid.'	
	end

	return filename, regression_type

end

# Read the given file and parse the x,y values into two separate
# arrays and returning to calling function.
def read_file(file)
	x = Array.new
	y = Array.new
	CSV.foreach(file, converters: :numeric, :headers => true) do |row|
		x << row['time']
		y << row['datapoint']
	end

	return x, y
end

# Takes x,y data points and the desired regression type and calculates the
# best equation that models the given data.
# 
def perform_regression(x, y, reg_type)
	if (reg_type == LOGARITHMIC)
		begin
			# Transform x to log(x)
			x = x.map { |x| Math.log(x) }
		rescue Math::DomainError
			# Raise the exception again here so we can catch it in either the main calling method
			# or from the best_fit calculation as both need to be handled differently and then we
			# can provide the correct error message.
			raise Math::DomainError, "Cannot perform logarithmic regression on this data"
		end
	elsif (reg_type == EXPONENTIAL)
		begin
			# Transform y to log(x)
			# Gives form of ln(y) = ln(a) + Bx
			y = y.map { |y| Math.log(y) }
		rescue Math::DomainError
			# Raise the exception again here so we can catch it in either the main calling method
			# or from the best_fit calculation as both need to be handled differently and then we
			# can provide the correct error message.
			raise Math::DomainError, "Cannot perform exponential regression on this data"
		end
	elsif (reg_type == POLYNOMIAL)
		return polynomial_regression(x, y)
	elsif (reg_type == BEST_FIT)
		best_coefficients ||= nil
		best_constant ||= nil
		best_r2 ||= -Float::INFINITY
		best_reg_type ||= ""

		# Calculate the coefficients for each regression type and compared the r^2 values in order
		# to determine which regression type results in the best fit.
		[LINEAR, EXPONENTIAL, LOGARITHMIC, POLYNOMIAL].each do |reg_type|
			begin
				results = perform_regression(x, y, reg_type)
			rescue Math::DomainError
				# If logarithmic or exponential regression cannot be performed
				# We do not want to terminate the program or print an error message
				# So we rescue the exception and do nothing
			end	

			# If we were able to obtain a result
			# i.e. if there was a exponential or logarithmic regression that couldn't be fitted.
			if (!results.kind_of? NilClass)
				if (results["r2"] > best_r2)
					best_r2 = results["r2"]
					best_coefficients = results["coefficients"]
					best_constant = results["constant"]
					best_reg_type = reg_type
				end
			end
		end


		results = {"coefficients" => best_coefficients, "constant" => best_constant,
				"r2" => best_r2, "reg_type" => best_reg_type}

		return results
	end

	if (reg_type != POLYNOMIAL)
		x = x.to_scale
		y = y.to_scale

		ds = {"x"=>x, "y"=>y}.to_dataset

		lr = Statsample::Regression.multiple(ds,"y")
		coefficients ||= lr.coeffs
		constant ||= lr.constant
		r2 ||= lr.r2
		# Do not round values here as they still may need to be modified.
	end

	results = {"coefficients" => coefficients, "constant" => constant, "r2" => r2}
	return results
end

# Calculates the polynomial regression for degrees 2..10.  Determines the r^2 values
# for each degree and returns the coefficients which model the data most accurately.
def polynomial_regression(x, y)
	mean_y = y.inject{ |sum, el| sum + el }.to_f / y.size

	# Calculate Total sum of squares
	tsos = y.inject { |sum, el| sum + (el - mean_y)**2 }.to_f

	best_r2 ||= -Float::INFINITY
	best_degree ||= 0
	best_coefficients ||= []

	(2..10).each do |deg|
		x_data = x.map { |x_i| (0..deg).map { |pow| (x_i**pow).to_f } }
		mx = Matrix[*x_data]	
		my = Matrix.column_vector(y)
		coefficients = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
		coefficients.map! {|coeff| coeff.round(2) }

		# Calculate residual sum of squares
		rsos = y.each_with_index.inject(0) do |sum, (el,i)|
			y_pred = coefficients.each_with_index.inject(0) do |y_sum, (coeff, j)|
				y_sum + (coeff*(x[i]**j))
			end
			sum + (el - y_pred)**2
		end

		# Calculate coefficient of determination
		r2 = 1 - (rsos/tsos)

		if (r2 > best_r2)
			best_r2 = r2
			best_degree = deg
			best_coefficients = coefficients
		end
	end
	
	results = {"coefficients" => best_coefficients, "r2" => best_r2}

	return results

end

# Takes coefficients, and the regression type and returns a string containing the specified equation.
def generate_equation(coefficients, constant, reg_type)
	if (reg_type == POLYNOMIAL)
		# Generate polynomail equation
		highest_power = coefficients.size - 1

		# Loop through each coefficient with index in reverse order injecting into the variable 'equation'
		equation = coefficients.to_enum.with_index.reverse_each.inject("") do |equation, (coefficient, i)|
			sign = "++-"[coefficient <=> 0]
			coefficient = coefficient.abs
			term = ""
			term << " " if (i < highest_power)
			term << "#{sign}" if (sign == "-" or i < highest_power)
			term << " " if (i < highest_power)
			term << "#{coefficient}"	
			term << "x" if (i > 0)
			term << "^#{i}" if (i > 1)
			equation << term
		end
	elsif (reg_type == EXPONENTIAL)
		a = Math.exp(constant).round(2)
		b = coefficients["x"].round(2)
		equation = "#{a}e^(#{b}x)"
	elsif (reg_type == LINEAR)
		a = constant.round(2)
		b = coefficients["x"].round(2)
		sign = "++-"[constant <=> 0]
		a = a.abs
		equation = "#{b}x #{sign} #{a}"
	elsif (reg_type == LOGARITHMIC)
		a = constant.round(2)
		b = coefficients["x"].round(2)
		sign = "++-"[constant <=> 0]
		a = a.abs
		equation = "#{b}ln(x) #{sign} #{a}"
	end

	return equation
end

# make this not run when required
if __FILE__ == $0
	
# Entry point
begin
	file, reg_type = read_arguments
rescue ArgumentError => e
	puts e.message + " Program terminating."
	exit(ARGUMENT_ERROR)
end
	
begin
	x, y = read_file(file)
rescue SystemCallError
	STDERR.puts "Invalid file path: '#{file}'. Program terminating."
	exit(FILE_PATH)
end
begin
	results = perform_regression(x, y, reg_type)
	if (reg_type == BEST_FIT)
		# If calculating best_fit we need to retrieve the best regression_type
		reg_type = results["reg_type"]
	end
rescue Math::DomainError => e
	STDERR.puts e.message
	exit(DOMAIN_ERROR)
end
equation = generate_equation(results["coefficients"], results["constant"], reg_type)
puts equation

end
