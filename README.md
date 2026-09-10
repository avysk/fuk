# Fuchs und Katzen

Implementation of a "Fox and Hounds" game in Forth for Agon Light
retro computer.

The Forth implementation the game is developed for is
[agon-forth](https://github.com/lennart-benschop/agon-forth/tree/main).

# Preparation

Copy `fuk.4th` and files from `vdus/` to the root directory of your SD card.
Capy all other `*.4th` files into `/forthlib/` directory (notice that Agon
Light Forth requires this directory to be in the root of SD card).

## Running

Start Forth from the root of SD card and enter

```forth
FLOAD fuk.4th
GAME
```

## Compiling

You can get a standalone binary. Start Forth from the root of your SD card and
enter

```forth
FLOAD fuk.4th
' GAME TURNKEY fuk.bin
```

Now you can exit Forth (with `BYE`) and remove all `*.4th` and vdu files you
copied to your SD card. Now you have a self-contained `fuk.bin` which can be
moved to anywhere and run.

# Playing the Game

You control 4 cats, and the program controls a fox. Cats and a fox can move one
square diagonally, if it is free (no jumping over pieces is allowed); the cats
can move only down-left or down-right; the fox can move in any of the four
directions. The fox wins either if reaches the topmost row of the board or if
no cat has a valid move. The cats win if the fox has no valid moves.

Each turn you can move a selected cat down-left (by pressing the left arrow) or
down-right (by pressing the right arrow) if the corresponding moves are valid.
The selected cat is marked by green border. To move selection to the next cat
having valid moes, press space.
