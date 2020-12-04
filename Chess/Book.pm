package Chess::Book;
use strict;
use warnings;

our %book = (
  # moves from opening
  'RNBQKBNRPPPPPPPP________________________________pppppppprnbqkbnr' => [
    [ 35, 55 ], # e4
    [ 34, 54 ], # d4
    [ 27, 46 ], # Nf3
    [ 33, 53 ], # c4
  ],
  # 1. e4
  'RNBQKBNRPPPPPPPP____________________p___________pppp_ppprnbqkbnr' => [
    [ 33, 53 ], # ... c5
    [ 35, 55 ], # ... e5
  ],
);

1;
