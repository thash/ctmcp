%% 5.3.2 非同期RMI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {ClientProc Msg}
   case Msg
   of work(?Y) then Y1 Y2 in
      % SendしたあとWaitしない
      {Send Server calc(10.0 Y1)}
      {Send Server calc(20.0 Y2)}
      Y=Y1+Y2 % ここで束縛を待つ
   end
end
Client={NewPortObject2 ClientProc}

{Browse {Send Client work($)}}
% 表示される結果自体は5.3.1と同じ
