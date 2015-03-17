%% 5.3.7 コールバックのある非同期RMI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {ServerProc Msg}
   case Msg
   of calc(X ?Y Client) then X1 D in
      {Send Client delta(D)}
      thread
         X1=X+D
         Y=X1*X1+2.0*X1+2.0
      end
   end
end
Server={NewPortObject2 ServerProc}

proc {ClientProc Msg}
   case Msg
   of work(?Y) then Y1 Y2 in
      {Send Server calc(10.0 Y1 Client)}
      {Send Server calc(20.0 Y2 Client)}
      thread Y=Y1+Y2 end
   [] delta(?D) then
      D=1.0
   end
end
Client={NewPortObject2 ClientProc}

% 次の呼び出しのメッセージ図式
declare Y in
{Send Client work(Y)}
{Browse Y} % => 630.0

% サーバがコールバックのあとでする仕事をthreadにしないとどうなるか?
% => Dが束縛されるのを待ち続ける
