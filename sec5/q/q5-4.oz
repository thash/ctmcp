% 終了検知

% SubThread定義
% 本文:
proc {SubThread P}
   {Send Pt 1}
   thread
      {P} {Send Pt ~1}
   end
end

% これを次のように書き換える:
proc {SubThread P}
   thread
      {Send Pt 1} {P} {Send Pt ~1}
   end
end

% すると動かなくなる．なぜか?