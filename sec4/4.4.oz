%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.4. 宣言的モデルを直接使うこと
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ストリーム通信以外にも宣言的並列モデルを実現する方法はある.
% ストリームオブジェクトといった"抽象"を使わずに宣言的並列モデルを「直接」使う, という話.

%% 4.4.1. 順序決定並列性(Order-determining concurrency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% どういう計算をするかはわかっているが, どういう順で計算するかはわからない.
% いままで見てきたデータフロー並列性は, 順序を自動的に見つける手段の一つ


%% 4.4.2. コルーチン
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% コルーチンは横取りなしのスレッド. 呼び出し元に戻る(return).
% コルーチン例はRubyのyield
% コルーチンはやはり非決定性を導入しないので, やっぱり宣言的なまま.
%
% コルーチンには spawnとresume という2つの操作がある.
% CId={Spawn P} は新しいコルーチンを生成してそのidentityをCIdに返す.
% どのコルーチンも, resumeによって制御を戻す責任がある(自分から手放さないといけない)
%
% Threadを使ってSpawn, Resumeを実装する.

declare
fun {Spawn P}
   PId in
   thread
      PId={Thread.this} % いま動いてる自分自身
      {Thread.suspend PId}
      {P}
   end
   Pid
end

proc {Resume Id}
   {Thread.resume Id}
   {Thread.suspend {Thread.this}}
end

%% 4.4.3. 並列的合成(Concurrent composition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% forkしたthreadのjoinのこと.
% Ozの場合はデータフロー変数があるのでメッセージ代わりにする.
% Waitは, 引数に渡された変数が束縛されるまで待つ. 待つだけの手続き.
local X1 X2 X3 in
   thread X1=unit end
   thread X2=X1 end
   thread X3=X2 end
   {Wait X3}
end

% 順々に待つ代わりに, 待つ専用のスレッドを生成するという方法も考えられる
local X1 X2 X3 Done in
   thread X1=unit end
   thread X2=unit end
   thread X3=unit end
   thread
      {Wait X1} {Wait X2} {Wait X3}
      Done=unit
   end
   {Wait Done}
end


% 制御抽象 ... ifとかそういう抽象
proc {Barrier Ps} % Psは手続きのリスト
   % それぞれの手続きをthreadとして実行し, 待つ.
   fun {BarrierLoop Ps L}
      case Ps of P|Pr then M in
         thread {P} M=L end
         {BarrierLoop Pr M}
      [] nil then L
      end
   end
   S={BarrierLoop Ps unit}
in
   {Wait S}
end


% 使ってみる
local X Y Z
in
   {Barrier [proc {$} Z=X*Y end
             proc {$} X=42  end
             proc {$} Y=70  end]}
end

% ↑のようなBarrier手続きを使って実装されたのがOzの
%     "conc"
% 言語抽象であるが, Barrierの方が汎用的.
