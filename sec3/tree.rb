module Tree

  module Empty
    def self.empty?
      true
    end

    def self.to_graph
      []
    end

    def self.val
      nil
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

    def to_graph
      []
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

    # 単純な深さ優先探索
    # ただの平坦配列にするので左, 右の情報が失われる
    def to_graph
      [ [val, l.val], [val, r.val] ]
        .concat(l.to_graph)
        .concat(r.to_graph)
        .reject{|pair| pair[1].nil? }
    end

    # usage: $ dot -T png -o out.png out.dot
    def to_dotfile(filename='out.dot')
      File.open(filename, 'w+') do |output|
        output << "digraph tree {\n"
        self.to_graph.each do |pair|
          output << "#{pair[0]} -> #{pair[1]};\n"
        end
        output << '}'
      end
      filename
    end
  end

end
