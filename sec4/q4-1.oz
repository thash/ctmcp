local B in
   thread B=true  end % 1
   thread B=false end % 2
   if B then          % 3
      {Browse yes}    % 4
   end
end

% (a) この文のあり得る実行を枚挙せよ

% イ. 何も出力せず異常終了...4まで辿り着かない
%    (1, 2), (2, 1)
%    (2, 3, 1)
%    (3, 1, 2)
%    (3, 2, 1)

% ロ. yesと表示してから以上終了
%    (1, 3, 4, 2)
%    (3, 1, 4, 2) % 1個目の"3"の時点では未束縛なので待機.

% (b) 異常終了を回避するには

%   単純にどっちかの束縛を外すか,
%   どちらかに確定した時点で他の束縛スレッドを殺してしまうとか.
