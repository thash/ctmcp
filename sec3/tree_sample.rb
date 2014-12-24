$: << '.'; require 'tree'

# http://cramster-image.s3.amazonaws.com/definitions/computerscience-5-img-1.png
t = Tree::Node.new(9,
                  l: Tree::Node.new(4,
                                   l: Tree::Leaf.new(3),
                                   r: Tree::Node.new(6,
                                                    l: Tree::Leaf.new(5),
                                                    r: Tree::Leaf.new(7))),
                  r: Tree::Node.new(17,
                                   l: Tree::Empty,
                                   r: Tree::Node.new(22,
                                                    l: Tree::Leaf.new(20),
                                                    r: Tree::Empty)))


`dot -T png -o out.png #{t.to_dotfile}`
`open out.png`
