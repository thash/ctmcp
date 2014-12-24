module Tree

  module Empty
    def self.empty?
      true
    end
  end

  class Leaf
    attr_accessor :val

    def initialize(val)
      @val = val
    end

    def empty?
      false
    end

    def insert(item)
      if item < val
        Node.new(val, l: Leaf.new(item))
      elsif item > val
        Node.new(val, r: Leaf.new(item))
      else
        self
      end
    end
  end

  class Node
    attr_accessor :val, :l, :r

    def initialize(val, l: Empty, r: Empty)
      @val = val
      @l = l
      @r = r
    end

    def empty?
      false
    end

    # 重複を許さない設計
    def insert(item)
      if item < val
        @l = l.empty? ? Leaf.new(item) : l.insert(item)
      elsif item > val
        @r = r.empty? ? Leaf.new(item) : r.insert(item)
      end
      self
    end
  end

end
