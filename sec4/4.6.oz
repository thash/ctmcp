%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.6. 甘いリアルタイムプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% soft real-time operation

%% 4.6.1. 基本操作
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 「甘い」 = なるべく期限を守ってね，という，厳格ではない時間制限．医療機器とかは厳しいリアルタイムが求められ，普通のPCでは実現不可能なので特殊な技術が必要．

% Timeモジュールの提供する甘いリアルタイム操作
%     1. {Delay I} : 実行中のスレッドを少なくともI ms中断
%     2. {Alarm I U} : 新しいスレッドを生成，少なくともI ms後にUにunitを束縛する．Delayで実装．
%     3. {Time.time} : 今年のはじめからの経過秒数(整数) ;; 今年って...

% "少なくとも" ってのが「甘い」. きっちりI msではない．

local
   proc {Ping N}
      if N==0 then {Browse 'ping terminated'}
      else {Delay 500} {Browse ping} {Ping N-1} end
   end

   proc {Pong N}
      {For 1 N 1
       proc {$ I} {Delay 600} {Browse pong} end}
      {Browse 'pong terminated'}
   end
in
   {Browse 'game started'}
   thread {Ping 50} end
   thread {Pong 50} end
end

% フツーに考えるとPingが500ms, Pongが600msおきに実行されるのでPong, Pongと連続することはなさそうだが，
% 「少なくとも」500ms中断するとしか言えず，もしかすると700ms中断するかもしれなくて，
% そうなるとPong, Pongと連続する可能性がある．このへんが甘い．


% スタンドアロンアプリケーション化(省略)


%% 4.6.2.  ティッキング(ticking)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Delayさせながら1秒ごとに伸びるストリームを生成
declare
fun {NewTicker1}
   fun {Loop}
      X={OS.localTime}
   in
      {Delay 1000}
      X|{Loop}
   end
in
   thread {Loop} end
end

% で，このストリームを読んでアクションを実行する別スレッドを作れば時間の軸に使える
thread for X in {NewTicker1} do {Browse X} end end

% たまに1秒欠落するかもしれない．なので，900秒ごとに誤差をチェックしてやる．
fun {NewTicker2}
   fun {Loop T}
      T1={OS.localTime}
   in
      {Delay 900}
      % ちゃんと進んでるかどうか
      if T1\=T then T1|{Loop T1} else {Loop T1} end
   end
in
   thread {Loop {OS.localTime}} end
end

% もっと良い方法は同期クロック(synchronized clock)を使うこと
fun {NewTicker3}
   fun {Loop N}
      T={Time.time}
   in
      if T>N then {Delay 900}
      elseif T<N then {Delay 1100}
      else {Delay 1000} end
      N|{Loop N+1}
   end
in
   thread {Loop {Time.time}} end
end
