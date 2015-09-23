% usage:
% /Applications/Mozart2.app/Contents/Resources/bin/ozc -e could_not_load_connection_oz

functor _
require % not import
  Connection
  % => ** Could not link module
  % => ** Could not load functor at URL: x-oz://system/Connection.ozf

  Pickel
  System

prepare % not define
  {System.showInfo 'hi'}
  {System.show hi(a:1 b:2)} % showInfo NG

  P MyTicket
  proc {P ?X}
    X=1
  end
  {Connection.offerUnlimited P MyTicket}
  {Pickel.save MyTicket "/Users/hash/work/ctmcp/sec11/a.ticket"}
end
