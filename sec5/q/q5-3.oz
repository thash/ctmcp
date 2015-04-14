% リフト制御システムのフォールトトレランス．起こりうる誤り2パターン想定して，それぞれの対処を考えよ

% http://www.eecs.ucf.edu/~leavens/COP4020Fall11/old-homeworks/Fall07/hw5-message-passing.pdf

% (a). リフトが故障する(原文"blocked"なので"故障"じゃないだろ)
%      リフトがある階で一時的に動かなくなっても，システム全体として稼働するように拡張せよ．
%      まず，階の機能を拡張し，ドアが開いているときにその階が呼ばれたらドアタイマをリセットするようにせよ．
%      そのあと，そのリフトのスケジュールを別のリフトに与え，階はそのリフトを呼べないようにする．
%      そのリフトが動くようになったら，階はまたそのリフトを呼べるようにする．制限時間を儲けてもよい．

% > Extend the system to continue working when a lift is temporarily blocked at a floor by a malicious user.
% > First extend the floor to reset the door timer when the floor is called while the doors are open.
% > Then the lift’s schedule should be given to other lifts and the floors should no longer call that particular lift.
% > When the lift works again, floors should again be able to call the lift.
% > This can be done with time-outs.

% 具体的にはopendoors -> close doors，の状態遷移の間にblockedを挟んでやるのかな

% (b). リフトが壊れる(out of order)
%      同期的検出と非同期的検出の両方が考えられる．
%      同期的検出: 壊れたコンポーネントにメッセージを送るとdown(Id)というレスがかえってくる
%      非同期的検出: 稼働稼働しているコンポーネント同士をlink，壊れたら他者にdownを送る．

% (c). 階が使えなくなる(A floor is out of order)

% (d). リフト保守(Lift maintenance)
%      あるリフトがメンテのために使えなくなり，後刻復旧する想定でシステムを拡張せよ

% (e). 相互作用(Interactions)
%      いくつかの階といくつかのリフトが同時に使えなくなったら?

