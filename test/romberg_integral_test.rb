require "test_helper"

class RombergIntegralTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RombergIntegral::VERSION
  end

  def test_gaussian
    f = -> x { Math.exp(-x**2/2) / Math.sqrt(2 * Math::PI) }
    expected = 0.49996832875817
    actual = RombergIntegral.new.integral 0, 4, &f
    assert_in_delta expected, actual.value, 1e-10
  end

  def test_sinex
    ri = RombergIntegral.new
    ri.relative_error = ri.absolute_error = 1e-6
    ri.min_call_cnt = ri.max_call_cnt = 65
    x1 = -1
    x2 = 3
    expected = sinex(x2) - sinex(x1)
    actual = ri.integral x1, x2, &method(:dsinex)
    expected_error = -0.005350074
    actual_error = actual.value - expected
    # Romberg integration converges at a defined rate -- not faster or
    # slower. Even if the error is less than expected, that is a
    # sign of a problem.
    assert_in_delta expected_error, actual_error, 1e-8
  end

  def sinex(x)
    Math.sin(Math.exp x)
  end

  def dsinex(x)
    ex = Math.exp x
    ex * Math.cos(ex)
  end
end
