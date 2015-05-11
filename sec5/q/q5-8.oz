%% ストリーム通信の限界

% 5.8.1 で，サーバ参照をデータ構造に入れる問題は部分的に解決することができると主張した．
% 部分的とはどの程度か? 次の能動的オブジェクトを考えよ．

declare NS
thread {NameServer NS nil} end

% ここで，NameServerは以下のように定義される．
fun {Replace InL A OldS NewS}
   case InL
   of B#S|L1 andthen A=B then
      OldS=S
      A#NewS|L1
   [] E|L1 then
      E|{Replace L1 A OldS NewS}
   end
end

proc {NameServer NS L}
   case NS
   of register(A S)|NS1 then
      {NameServer NS1 A#S|L}
   [] getstream(A S)|NS1 then L1 OldS NewS in
      L1={Replace L A OldS NewS}
      thread {StreamMerger S NewS OldS} end
      {NameServer NS1 L1}
   [] nil then
      skip
   end
end

% サーバ参照をデータ構造に入れることができたように見える．
% これは実用的な解か?
% => 脚注によれば「名前サーバに名前をつけることはできない！すべての手続きに引数として追加しなければならない．この引数を消去するには明示的状態が必要である」とのこと