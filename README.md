# Bathysphere

https://boardgamegeek.com/boardgame/255360/bargain-basement-bathysphere

## Running It

* `mix deps.get`
* `iex -S mix`
```
Erlang/OTP 22 [erts-10.7] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.10.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Bathysphere.display
 ↕️ |  Start / End   |
   |     -1 O₂      |
   |  -1 O₂ / -2 S  |
   |                |
   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
   |    Octopus     |
   | XXXXXXXXXXXXXX |
   |      -1 D      |
   |    +2 Floor    |
:ok
iex(2)> Bathysphere.down   
:ok
iex(3)> Bathysphere.down
:ok
iex(4)> Bathysphere.display
   |  Start / End   |
   |     -1 O₂      |
 ↕️ |  -1 O₂ / -2 S  |
   |                |
   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
   |    Octopus     |
   | XXXXXXXXXXXXXX |
   |      -1 D      |
   |    +2 Floor    |
:ok
iex(5)> Bathysphere.up     
:ok
iex(6)> Bathysphere.display
   |  Start / End   |
 ↕️ |     -1 O₂      |
   |  -1 O₂ / -2 S  |
   |                |
   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
   |    Octopus     |
   | XXXXXXXXXXXXXX |
   |      -1 D      |
   |    +2 Floor    |
:ok
```
