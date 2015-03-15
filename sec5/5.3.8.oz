%% 5.3.8 二重コールバック
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {ServerProc Msg}
   case Msg
   of calc(X ?Y Client) then X1 D in
      {Send Client delta(D)}
      thread % 送信後の処理は先程と同じく別thread
         X1=X+D
         Y=X1*X1+2.0*X1+2.0
      end
   [] serverdelta(?S) then
      % サーバのメソッドserverdelta(S)はクライアントのdelta(D)から呼ばれる
      S=0.01
   end
end
Server={NewPortObject2 ServerProc}

proc {ClientProc Msg}
   case Msg
   of work(Z) then Y in
      {Send Server calc(10.0 Y Client)}
      thread Z=Y+100.0 end
   [] delta(?D) then S in
      {Send Server serverdelta(S)}
      thread D=1.0+S end
   end
end
Client={NewPortObject2 ClientProc}

% 実行
{Send Client work(Z)}

% なぜD=1.0+Sはスレッドになっているか?