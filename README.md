# PerlChess
Chess engine in Perl

## Overview
This is a simple Chess Engine written in Perl. Originally, I had created it for my NaNoGenMo 2017 entry, ["White to Play and Win"](https://github.com/greg-kennedy/ChessBook). I wanted to continue development on the engine, but had no place for it within the novel repository. Instead, I have split it into a standalone project.

It is still not very good, for a number of reasons:
* opening book is extremely limited
* static evaluator lacks heuristics beyond raw piece value
* no endgame intelligence
* and it's too slow to use beyond 5 or 6 ply

Some of this may be improved in the future, or not.

## Usage
The engine code itself is stored in the `Chess` folder as a set of related Perl modules:

* `Constant.pm` - definitions of constants used by the other modules
* `State.pm` - holds the board representation and game history, generates move lists and verifies moves
* `Engine.pm` - implements the Negamax algorithm with Alpha-Beta pruning to determine the best next move
* `Book.pm` - opening book for the engine

To interact with the engine from other programs, simply `use` (or `require`) the desired components. There are POD comments at the top of each module file to help explain the methods.

## Examples
A few example programs are included in the main repository:

* `perft.pl` - the Perft move-testing program. Exercises the move generation in Chess::Board and returns how many nodes were visited. Used to verify correctness of move generation.
* `play.pl` - console-based version of the game which lets a user play against the computer
* `uci.pl` - a UCI (Universal Chess Interface) adapter, which allows the program to be linked to a Chess GUI like Arena or WinBoard. Using a remote SSH connection with e.g. `plink` (part of the PuTTY suite) it can even run on a networked machine.

## Notes
Internally the board is treated as a flattened 10x12 array (120 elements) with move generation using offsets. Also, the board is stored "flipped" for Black, which makes things easier on the engine - it simply acts as though it is always playing White (a "monochrome" chess engine).

Development of this engine would have been much more difficult without the tremendous resource of the [Chess Programming Wiki](https://www.chessprogramming.org/), which covers a range of topics relating to creating and testing chess engines.

## License
Released under the Perl Artistic 2.0 license.
