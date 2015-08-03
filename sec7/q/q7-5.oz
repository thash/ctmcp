% 5.3 のメッセージプロトコルを再実装.
% ポートオブジェクトの代わりに能動的オブジェクトを使うように

declare
class Server
  attr f
  meth init(F)
    f:=F
  end
  meth calc(X Y)
    Y={@f X}
  end
end
S={NewSync Server init(fun {$ X} X*X+2.0*X+2.0 end)}

declare
class Client
  attr server
  meth init(S)
    server:=S
  end
  meth work(Y)
    Y={@server }
  end
end
