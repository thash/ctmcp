% 名前呼び出し

% 明示的状態と引数の遅延計算が好ましくない相互作用をする例
procedure swap(callbyname x,y:integer);
var t:integer;
begin
t:=x; x:=y; y:=t
end;
var a:array [1..10] of integer;
var i:integer;
i:=1; a[1]:=2; a[2]=1; % a[2]だけ=になってる

swap(i, a[i])
writeln(a[1], a[2]);

% 上の例の挙動を, 名前呼び出しの理解に基づいて説明せよ

% この例を，状態あり計算モデルでコーディングせよ. array[1..10]は以下のようにする
A={MakeTuple array 10}
for J in 1..10 do A.J={NewCell 0} end

