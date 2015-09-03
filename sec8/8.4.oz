%% 8.4. モニタ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 状態ありモデルにおいてスレッドを強調させる方法.
% ロックを拡張(wait, notify を加える)し，待機中のスレッドがロックに出入りするのをプログラムで制御するもの

% "Java 言語の基本概念になっている"
% synchronized と注記することでオブジェクトのメソッドをロックにより防御できる.
% wait, notify, notifyAll がある．ロックを保持してるスレッドだけがこれらを呼べる．
% wait を呼ぶと wait 集合に自身を突っ込み，ロックを開放する

% fig 8.16 - 有界バッファ(不完全)
declare
class Buffer
   attr
      buf first last n i

   meth init(N)
      buf:={NewArray 0 N-1 null}
      first:=0 last:=0 n:=N i:=0
   end

   meth put(X)
      ... % wait until i<n
      % now add an element:
      @buf.@last:=X
      last:=(@last+1) mod @n
      i:=@i+1
   end

   meth get(X)
      ... % wait until i>0
      % now remove an element:
      X=@buf.@first
      first:=(@first+1) mod @n
      i:=@i-1
   end
end

% 上記figのputメソッド定義 - まだ不完全版
meth put(X)
   {M.'lock' proc {$}
                if @i>=@n then {M.wait} end
                @buf.@last:=X
                last:={@last+1} mod @n
                i:=@i+1
                {M.notifyAll}
             end}
end

% バッファがいっぱいであればputできないので空くまでwaitしてる．
% が，この定義ではM.waitでロックを手放した直後他のスレッドが要素を突っ込む可能性がある
% ので，正解は@i>=@nするたびに必要なだけ{M.wait}すること ;; "必要なだけ"?

meth put(X)
   {M.'lock' proc {$}
                % waitで手放したあと，再度自身を呼んでチェックし直す.
                % "チェックは危険領域の中で行われ，他のスレッドから干渉される恐れがない"
                if @i>=@n then {M.wait} {self put(X)}
                else
                   @buf.@last:=X
                   last:={@last+1} mod @n
                   i:=@i+1
                   {M.notifyAll}
             end}
end


% fig 8.17 - 有界バッファモニタ版(完全版)
% get の方も考え方は同じ. 中身空ならgetしようがない
declare
class Buffer
   attr m buf first last n i

   meth init(N)
      m:={NewMonitor}
      buf:={NewArray 0 N-1 null}
      n:=N i:=0 first:=0 last:=0
   end

   meth put(X)
      {@m.'lock' proc {$}
         if @i>=@n then {@m.wait} {self put(X)}
         else
            @buf.@last:=X
            last:=(@last+1) mod @n
            i:=@i+1
            {@m.notifyAll}
         end
      end}
   end

   meth get(X)
      {@m.'lock' proc {$}
         if @i==0 then {@m.wait} {self get(X)}
         else
            X=@buf.@first
            first:=(@first+1) mod @n
            i:=@i-1
            {@m.notifyAll}
         end
      end}
   end
end


%% 8.4.3. モニタを使うプログラミング

% 真偽条件式で"防護"する "条件付き危険領域 (conditional critical section)"
% <expr> が防護
% <stmt> が防護された本体
meth methHead
   lock
      while not <expr> do wait;
      <stmt>
      notifyAll;
   end
end


%% 8.4.4. モニタを実装すること

% fig 8.18 - キュー(並列状態あり拡張版)
declare
fun {NewQueue}
   ...
   fun {Size}
      lock L then @C.1 end
   end
   fun {DeleteAll}
      lock L then
      X q(_ S E)=@C in
         C:=q(0 X X)
         E=nil S
      end
   end
   fun {DeleteNonBlock}
      lock L then
         if {Size}>0 then [{Delete}] else nil end
      end
   end
in
   queue(insert:Insert delete:Delete size:Size
         deleteAll:DeleteAll deleteNonBlock:DeleteNonBlock)
end


% fig 8.19 - ロック(再入 get-release 版)
% get-release ロックを使った相互排除(Mutual exclusion)の実装
% ロックの獲得/手放し, をそれぞれGetLock, ReleaseLockという個別の操作として抽出する方式.
% キューを使ってwait集合を実装すると，最初にモニタに入る機会が最長待機スレッドに与えられるので餓死(starvation)が起きない
declare
fun {NewGRLock}
   Token1={NewCell unit}
   Token2={NewCell unit}
   CurThr={NewCell unit}

   fun {GetLock}
      if {Thread.this}\=@CurThr then Old New in
         {Exchange Token1 Old New}
         {Wait Old}
         Token2:=New
         CurThr:={Thread.this}
         true
      else false end
   end

   proc {ReleaseLock}
      CurThr:=unit
      unit=@Token2
   end
in
   'lock'(get:GetLock release:ReleaseLock)
end


% fig 8.20
declare
fun {NewMonitor}
   Q={NewQueue}
   L={NewGRLock}

   proc {LockM P}
      if {L.get} then
         try {P} finally {L.release} end
      else {P} end
   end

   proc {WaitM}
   X in
      {Q.insert X} {L.release} {Wait X}
      if {L.get} then skip end
   end

   proc {NotifyM}
   U={Q.deleteNonBlock} in
      case U of [X] then X=unit else skip end
   end

   proc {NotifyAllM}
   L={Q.deleteAll} in
      for X in L do X=unit end
   end
in
   monitor('lock':LockM wait:WaitM notify:NotifyM
           notifyAll:NotifyAllM)
end


% 状態共有並列モデルにおいて並列プログラムを書く時，
% 普通モニタよりデータフロー手法を使うほうが簡単. Mozart はモニタの性能放置してる


% 8.4.5 モニタの別の意味

% ここまでの議論ではnotifyは単に"待機中の1つのスレッドがwait集合を離れるようにすること"というただひとつの効果を持っていた

% => "変種"を考える. notifyが
%    "待機中の1つのスレッドをwait集合から出し" て，さらに
%    "モニタロックをそのスレッドに移す" ところまで原子的に世話してやるバージョン.
%     この場合notifyAllはもはや意味なくなる

% この変種で有界バッファを実装し直すとすれば,
%   * 有界バッファはnonempty, nonfull のふたつの防護条件を持つ
%   * put メソッドはnonfull が真になるのを待ち, nonemptyを合図する(?)
%   * get メソッドはnonemptyが真になるのを待ち，nonfull を合図する(?)
% スレッド選択が限定的なので前の実装よりも効率が良くなる. 実装は練習問題にて.
