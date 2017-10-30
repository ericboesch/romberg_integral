require "romberg_integral/version"

# Class to numerically estimate the integral of a function using
# Romberg integration, a faster relative of Simpson's method.
#
# == About the algorithm
#
# Romberg integration uses progressively higher-degree polynomial
# approximations each time you double the number of sample points. For
# example, it uses a 2nd-degree polynomial approximation (as Simpson's
# method does) after one split (<tt>2**1 + 1</tt> sample points), and
# it uses a 10th-degree polynomial approximation after five splits
# (<tt>2**5 + 1</tt> sample points). Typically, this will greatly
# improve accuracy (compared to simpler methods) for smooth functions,
# while not making much difference for badly behaved ones.
class RombergIntegral
  # Each stage of Romberg integration nearly doubles the total number
  # of function calls: specifically, the total calls made at the end
  # of stage +n+ equals <tt>2**n+1</tt>. So, for example, the stage
  # +1+ estimate uses 3 function calls total, and stage +2+ adds 2
  # more function calls for a total of +5+.
  #
  # The absolute error estimate after stage +n+ equals
  #
  #     Math.abs(stage_n_estimate - stage_n_minus_1_estimate)
  #
  # If the total number of function calls made so far is greater than
  # or equal to +min_call_cnt+ and the absolute error estimate is no
  # greater than this value, then +#integral+ returns.
  #
  # Default value is +1e-20+.
  attr_accessor :absolute_error

  # The relative error is defined as
  #
  #     absolute_error_estimate / integral_estimate
  #
  # If the total number of function calls made so far is greater than
  # or equal to +min_call_cnt+ and the relative error estimate is no
  # greater than this value, then +#integral+ returns.
  #
  # Default value is +10**-10+. The accuracy limit of double-precision
  # floating point is about +10**-15+, but the best accuracy actually
  # achievable is often less than the double precision limit.
  attr_accessor :relative_error

  # Minimum number of calls to +f+ to make before checking whether the
  # error estimate is below the absolute or relative threshold.
  #
  # Default value is 33.
  attr_accessor :min_call_cnt

  # Maximum number of calls to +f+ to make before +#integral+ aborts.
  # This number is rounded up to the next value of the form <tt>2**n +
  # 1</tt> which is also greater than or equal to +min_call_cnt+. For
  # example, a value of 50 is treated like <tt>65 = 2**6 + 1</tt>.
  #
  # Default value is 65537.
  attr_accessor :max_call_cnt
  
  def initialize
    @aborted = false
    @relative_error = 1e-10
    @absolute_error = 1e-20
    @max_call_cnt = 65537
    @min_call_cnt = 33
  end

  # *x1:: lower bound of integration. Must be finite.
  # *x2:: upper bound of integration. Must be finite.
  #
  # Returns a +RombergIntegral::Estimate+ struct with the following
  # methods:
  #
  # *value:: The best estimate value
  # *aborted?::
  #     True if and only if neither the relative_error nor
  #     absolute_error thresholds were met, but instead the
  #     calculation terminated due to detected loss of precision or
  #     reaching the max_call_cnt threshold.
  # *call_cnt:: Number of times f() was called during the estimation process.
  # *absolute_error:: Equals
  #    Math.abs(estimate-previous_stage_estimate). The relative error
  #    can be computed as absoulte_error/estimate, unless estimate
  #    equals zero.
  # *relative_error:: absolute_error / estimate, or nil if estimate == 0
  def integral(x1, x2, &f)
    x1, x2 = [x2, x1] if x1 > x2

    # total is used to compute the trapezoid approximations.  It is more or
    # less a total of all f() values computed so far.  The trapezoid
    # method assigns half as much weight to f(x2) and f(x1) as it does to
    # all other f() values, so f(x2) and f(x1) are divided by two here.
    total = (yield(x1) + yield(x2))/2.0
    call_cnt = 2
    step_len = (x2 - x1).to_f

    estimate = total * step_len # 0th trapezoid approximation.
    row = [estimate]
    split = 1
    steps = 2
    aborted = false
    abs_error = nil

    loop do
      # Don't let step_len drop below the limits of numeric precision.
      # (This should prevent infinite loops, but not loss of accuracy.)
      if x1 + step_len/steps == x1 || x2 - step_len/steps == x2
        aborted = true
        break
      end

      # Compute the (split)th trapezoid approximation.
      x = x1 + step_len/2
      while x < x2
        total += yield(x)
        call_cnt += 1
        x += step_len
      end
      row.unshift total * step_len / 2

      # Compute the more refined approximations, based on the (split)th
      # trapezoid approximation and the various (split-1)th refined
      # approximations stored in @row.
      pow4 = 4.0
      1.upto(split) do |td|
        row[td] = row[td-1] + (row[td-1]-row[td])/(pow4 - 1)
        pow4 *= 4
      end

      # row[0] now contains the (split)th trapezoid approximation,
      # row[1] now contains the (split)th Simpson approximation, and
      # so on up to row[split] which contains the (split)th Romberg
      # approximation.

      # Is this estimate accurate enough?
      old_estimate = estimate
      estimate = row[-1]
      abs_error = (estimate - old_estimate).abs
      if call_cnt >= min_call_cnt
        break if abs_error <= absolute_error ||
                 abs_error <= relative_error * estimate.abs
        if call_cnt >= max_call_cnt
          aborted = true
          break
        end
      end
      split += 1
      step_len /=2
      steps *= 2
    end

    Estimate.new(estimate, aborted, call_cnt, abs_error)
  end

  Estimate = Struct.new(:value, :aborted, :call_cnt, :absolute_error) do
    def aborted?
      aborted
    end
    
    def relative_error
      value.zero? ? nil : absolute_error / value
    end
  end
end
