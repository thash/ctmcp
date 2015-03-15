%% 5.3.5 RMI with callback (using procedure continuation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Serverは5.3.4のままで，Clientを変更する．
declare
proc {ClientProc Msg}
   case Msg
   of work(?Z) then
      % 戻った時にやるべき仕事をパターンマッチ下に用意するのではなく，
      % 手続きとしてサーバに送る
      C=proc {$ Y} Z=Y+100.0 end
   in
      {Send Server calc(10.0 Client cont(C))}
   [] cont(C)#Y then
      % ここでは手続きを実行するのみ
      {C Y}
   [] delta(?D) then
      D=1.0
   end
end
Client={NewPortObject2 ClientProc}

{Browse {Send Client work($)}}
