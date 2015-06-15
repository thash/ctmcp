%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6.9. 進んだ話題
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 6.9.1. 状態ありプログラミングの限界
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% オブジェクト指向プログラミングは状態ありプログラミングの特別な場合
% 限界: 並列性，AND/OR 分散と共存するのが難しい
% 状態あり分散プログラミングはトリッキー


%% 6.9.2. メモリ管理と外部参照
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 最終化 (Finalize)

declare [Finalize]={Module.link ['x-oz://system/OPIEnv.ozf']}
{Browse Finalize}
{Browse Finalize.register}

{Finalize.register X P}
% 参照Xと手続きPを登録する
% Xが到達不能になると，"いずれ(eventually)" {P X}がスレッドとして実行される

{Finalize.everyGC P}
% 手続きPは，GCが終了するたびに起動される

% everyGCの定義は以下の通り
proc {EveryGC P}
   proc {DO _} {P} {Finalize.register DO DO} end
in
   {Finalize.register DO DO}
end


%% 遅延性と外部資源
% 全部読み終わるか，もしくは必要でなくなったらファイルをCloseする処理
declare [File]={Module.link ['/Users/hash/work/ctmcp/File.ozf']}
fun {ReadListLazy FN}
   {File.readOpen FN}
   fun lazy {ReadNext}
      L T I in
      {File.readBlock I L T}
      if I==0 then T=nil {File.readClose} else T={ReadNext} end
      L
   end
in
   {Finalize.register F proc {$ F} {File.readClose} end}
   {ReadNext}
end
