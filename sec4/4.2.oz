%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.2. スレッドプログラミングの基本的技法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 4.2.1. スレッドを生成すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

thread
   proc {Count N} if N>0 then {Count N-1} end end
in
   {Count 1000000}
end

% thread...endという書き方は式としても使える. すなわち値を返す.
declare X in
X = thread 10*10 end + 100*100
{Browse X} % => 10100

% 先の書き方は以下の糖衣構文である.
declare X in
local Y in
   thread Y=10*10 end
   X=Y+100*100
end

% メインスレッドと新しいスレッドの通信のためにデータフロー変数Yが生成され,
% 10*10の計算が完了するまで足し算はブロックする

% スレッドの実行は横取り(preemptive)方式で実装される. どのスレッドもタイムスライス(time slice)単位でプロセッサの時間を使う.


%% 4.2.2. スレッドとブラウザ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ブラウザは並列環境で動くプログラムの好例
thread {Browse 111} end
{Browse 222}
% を実行すると, どちらが先に表示される場合もある.

% ブラウザは並列的に動くよう設計されているので, 複数のストリームをちゃんと分けて表示する.
declare X1 X2 Y1 Y2 in
thread {Browse X1} end
thread {Browse Y1} end
thread X1=all|roads|X2 end
thread Y1=all|roams|Y2 end
thread X2=lead|to|rome|_ end
thread Y2=lead|to|rhodes|_ end


%% 4.2.3. スレッドを使うデータフロー計算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare X0 X1 X2 X3 in
thread
   Y0 Y1 Y2 Y3 in
      {Browse [Y0 Y1 Y2 Y3]}
      Y0=X0+1
      Y1=X1+Y0
      Y2=X2+Y1
      Y3=X3+Y2
      {Browse completed}
end
{Browse [X0 X1 X2 X3]}

% この時点ではすべて未束縛. 順々にXに値を投入していく.

X0=0
% => [0 _ _ _]
% => [1 _ _ _]
X1=1
% => [0 1 _ _]
% => [1 2 _ _]
X2=2
% => [0 1 2 _]
% => [1 2 4 _]
X3=3
% => [0 1 2 3]
% => [1 2 4 7]
% => completed


%% 並列的状況で宣言的プログラムを使うこと
declare ForAll
proc {ForAll L P}
   case L of nil then skip
   [] X|L2 then {P X} {ForAll L2 P} end
end

declare L in
thread {ForAll L Browse} end

% 別のスレッドからLを束縛する
declare L1 L2 in
thread L=1|L1 end
thread L1=2|3|L2 end
thread L2=4|nil end

% 直列に書いても出力は同じ
{ForAll [1 2 3 4] Browse}


%% 並列Map関数
declare Map
fun {Map Xs F}
   case Xs of nil then nil
   [] X|Xr then thread {F X} end|{Map Xr F} end
end

declare F Xs Ys Zs
{Browse thread {Map Xs F} end}

% ここまで実行すると, Xsが束縛されてないので新しいスレッドは生成されてすぐ待機に入る.
% 次に以下の文を実行
Xs=1|2|Ys % => _|_|_
fun {F X} X*X end % => 1|4|_

Ys=3|Zs % => 1|4|9|_
Zs=nil  % => 1|4|9|nil


%% 並列フィボナッチ関数
declare Fib
fun {Fib X}
   if X=<2 then 1
   else thread {Fib X-1} end + {Fib X-2} end
end
{Browse {Fib 26}}

% Ozパネル


% 4.2.4. スレッドのスケジューリング
% 4.2.5. 協調的並列性と競合的並列性
% 4.2.6. スレッド操作
