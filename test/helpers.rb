# Extend Test::Unit::TestCase with a few useful helper methods, additional
# assert methods, etc.
class Test::Unit::TestCase
  # Call this in a no-op test function. This will let the test case pass, but
  # will printout a warning that it is not implemented.
  def no_test
    Kernel.caller[0] =~ /(.*\/)*(.*)\.rb:.*:in\s+`(.*)'/
    puts "\n\nWARNING: Test not implemented:"
    puts "    Test Case: #{$2}"
    puts "    Test Func: #{$3}"
    puts "\n"
  end

  # Call this in a test function that is no longer working if you want to
  # just print out a warning that the test is broken or out of date, but
  # don't want it to fail the tests and also don't want to remove it.
  def broken_test
    Kernel.caller[0] =~ /(.*\/)*(.*)\.rb:.*:in\s+`(.*)'/
    puts "\n\nWARNING: This test has become broken and needs to be fixed:"
    puts "    Test Case: #{$2}"
    puts "    Test Func: #{$3}"
    puts "\n"
  end

  # Asserts that the given block rasies a RuntimeError with the
  # specified error string.
  def assert_fault(fault_string)
    err = nil
    begin
      yield
    rescue RuntimeError => err
    rescue Exception
        raise
    end
    
    assert_not_nil(err)
    assert_equal(fault_string, err.message)
  end
end
