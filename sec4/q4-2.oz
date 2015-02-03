% _ は未束縛, 引数を捨てる. Goで返り値捨てる時みたいな.
proc {B _}
   {Wait _} % 永遠に待つ. Bに何か渡してもここで未束縛
end

proc {A}
   Collectable={NewDictionary}
in
   {Browse invoke}
   {B Collectable}
   {Browse done} % => ここまで届かない
end

% Aの呼び出しが終わるとCollectableはgarbageになるか?
{A}
% => そもそも呼び出しが終わらない. {B Hoge} で永遠に待つ.
% Garbageが回収できるか
% _はいらないよ, なので捨てていい
