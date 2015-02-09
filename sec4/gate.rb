require 'minitest/autorun'

module Gate
  def self.not(a)     "%0#{a.length}b" % (~(a.to_i(2)) & 1)      end
  def self.and(a, b)  "%0#{[a.length, b.length].min}b" % (a.to_i(2) & b.to_i(2)) end
  def self.or(a, b)   "%0#{[a.length, b.length].min}b" % (a.to_i(2) | b.to_i(2)) end
  # def self.xor(a, b)  "%0#{a.length}b" % (a.to_i(2) ^ b.to_i(2)) end
  def self.xor(a, b) # Rubyの^を使わないver
    "%0#{[a.length, b.length].min}b" %
    self.or(self.and(self.not(a), b),
            self.and(a, self.not(b)))
  end

  # [sum, carry]
  def self.half_adder(a, b)
    [self.xor(a, b), self.and(a, b)]
  end

  # http://rosettacode.org/wiki/Four_bit_adder#Ruby
  # http://ja.wikipedia.org/wiki/%E5%8A%A0%E7%AE%97%E5%99%A8
  # [sum, carry]
  # full_adder自体は1桁の足し算しか出来ない
  def self.full_adder(a, b, c0)
    s, c  = half_adder(c0, a)
    s1, c1 = half_adder( s, b)
    [s1, self.or(c, c1)]
  end

  # full_adderを利用して複数桁足し算を実装
  def self.four_bit_adder(a, b)
    # puts "four_bit_adder: #{a} + #{b}"
    s0, c0 = full_adder(a[0], b[0], '0')
    s1, c1 = full_adder(a[1], b[1], c0)
    s2, c2 = full_adder(a[2], b[2], c1)
    s3, c3 = full_adder(a[3], b[3], c2)
    [[s0, s1, s2, s3].join, c3.to_s]
  end
end

class TestGate < MiniTest::Unit::TestCase

  def test_bitwise
    assert_equal( 2,   "0010".to_i(2))
    assert_equal( 5,   "0101".to_i(2))
    assert_equal(-6, ~("0101".to_i(2)))
    assert_equal( 2,  0b0010)
    assert_equal( 5,  0b0101)
    assert_equal(-6, ~0b0101)
    assert_equal(  '0010', "%04b" %  (0b010))
    assert_equal(  '0101', "%04b" %  (0b101))
    assert_equal('..1010', "%04b" % ~(0b101))
    assert_equal('..1010',  "%4b" % ~(0b101))
    assert_equal('..1010',   "%b" % ~(0b101))
  end

  def test_not_one
    assert_equal '1', Gate.not('0')
    assert_equal '0', Gate.not('1')
  end

  def test_and_one
    assert_equal '0', Gate.and('0', '0')
    assert_equal '0', Gate.and('1', '0')
    assert_equal '0', Gate.and('0', '1')
    assert_equal '1', Gate.and('1', '1')
  end

  def test_or_one
    assert_equal '0', Gate.or('0', '0')
    assert_equal '1', Gate.or('1', '0')
    assert_equal '1', Gate.or('0', '1')
    assert_equal '1', Gate.or('1', '1')
  end

  def test_xor_one
    assert_equal '0', Gate.xor('0', '0')
    assert_equal '1', Gate.xor('1', '0')
    assert_equal '1', Gate.xor('0', '1')
    assert_equal '0', Gate.xor('1', '1')
  end

  def test_and
    assert_equal '0000', Gate.and('1010', '0101')
    assert_equal '0101', Gate.and('0101', '0101')
    assert_equal '0101', Gate.and('1111', '0101')
  end

  def test_half_adder
    assert_equal ['0', '0'], Gate.half_adder('0', '0')
    assert_equal ['1', '0'], Gate.half_adder('0', '1')
    assert_equal ['1', '0'], Gate.half_adder('1', '0')
    assert_equal ['0', '1'], Gate.half_adder('1', '1')
  end

  # p %w(0 1).repeated_permutation(3).to_a
  def test_full_adder
    assert_equal ['0', '0'], Gate.full_adder('0', '0', '0')
    assert_equal ['1', '0'], Gate.full_adder('0', '0', '1')
    assert_equal ['1', '0'], Gate.full_adder('0', '1', '0')
    assert_equal ['0', '1'], Gate.full_adder('0', '1', '1')
    assert_equal ['1', '0'], Gate.full_adder('1', '0', '0')
    assert_equal ['0', '1'], Gate.full_adder('1', '0', '1')
    assert_equal ['0', '1'], Gate.full_adder('1', '1', '0')
    assert_equal ['1', '1'], Gate.full_adder('1', '1', '1')
  end

  # 全加算器の利用
  # 4bitの数値は0(0000)から15(1111)までを表せる．2数を足そうとすると途中で繰り上がりが発生するが，全加算器を使うことで繰り上がり(carry)を扱える
  def test_full_adder_4bit
    puts "\n%2s + %2s = %4s + %4s = %s %4s = %s" % %w(A B binA binB c sum result)
    puts '----------------'
    0.upto(15) do |a|
      0.upto(15) do |b|
    # a = 15
    # b = 1
        bin_a = '%04b' % a
        bin_b = '%04b' % b
        sum, carry = Gate.four_bit_adder(bin_a, bin_b)
        puts "%2d + %2d = %s + %s = %s %s = %2d" %
             [a, b, bin_a, bin_b, carry, sum, (carry + sum).to_i(2)]
      end
    end
  end
end
