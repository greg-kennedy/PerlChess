package Chess::Constant;
use v5.008;
use strict;
use warnings;

use utf8;

##########################################################
# SOME CONSTANTS
#  Importing this pollutes your environment very badly :)

our @EXPORT = qw( OOB EMPTY
    PAWN KNIGHT BISHOP ROOK QUEEN KING
    OPP_PAWN OPP_KNIGHT OPP_BISHOP OPP_ROOK OPP_QUEEN OPP_KING
    CASTLE_KING CASTLE_QUEEN %p2f %p2l %l2p );

use Exporter;
our @ISA = qw(Exporter);

# whose turn
#use constant WHITE => 0;
#use constant BLACK => 1;

# type of piece (any color)
use constant {
  EMPTY => 0,

  PAWN => 1,
  KNIGHT => 2,
  BISHOP => 3,
  ROOK => 4,
  QUEEN => 5,
  KING => 6,

  OOB => 7,

  OPP_PAWN => -1,
  OPP_KNIGHT => -2,
  OPP_BISHOP => -3,
  OPP_ROOK => -4,
  OPP_QUEEN => -5,
  OPP_KING => -6,

  OPP_OOB => -7,

  CASTLE_KING => 0,
  CASTLE_QUEEN => 1
};

# conversion between piece const and letter
=pod
our %p2f = (
  WHITE_PAWN, '♙',
  WHITE_KNIGHT, '♘',
  WHITE_BISHOP, '♗',
  WHITE_ROOK, '♖',
  WHITE_QUEEN, '♕',
  WHITE_KING, '♔',

  BLACK_PAWN, '♟',
  BLACK_KNIGHT, '♞',
  BLACK_BISHOP, '♝',
  BLACK_ROOK, '♜',
  BLACK_QUEEN, '♛',
  BLACK_KING, '♚'
);

our %l2p = (
  P => WHITE_PAWN,
  N => WHITE_KNIGHT,
  B => WHITE_BISHOP,
  R => WHITE_ROOK,
  Q => WHITE_QUEEN,
  K => WHITE_KING,

  p => BLACK_PAWN,
  n => BLACK_KNIGHT,
  b => BLACK_BISHOP,
  r => BLACK_ROOK,
  q => BLACK_QUEEN,
  k => BLACK_KING
);

our %p2l = (
  WHITE_PAWN, 'P',
  WHITE_KNIGHT, 'N',
  WHITE_BISHOP, 'B',
  WHITE_ROOK, 'R',
  WHITE_QUEEN, 'Q',
  WHITE_KING, 'K',

  BLACK_PAWN, 'p',
  BLACK_KNIGHT, 'n',
  BLACK_BISHOP, 'b',
  BLACK_ROOK, 'r',
  BLACK_QUEEN, 'q',
  BLACK_KING, 'k'
);
=cut

our %p2f = (
  PAWN, '♙',
  KNIGHT, '♘',
  BISHOP, '♗',
  ROOK, '♖',
  QUEEN, '♕',
  KING, '♔',

  OPP_PAWN, '♟',
  OPP_KNIGHT, '♞',
  OPP_BISHOP, '♝',
  OPP_ROOK, '♜',
  OPP_QUEEN, '♛',
  OPP_KING, '♚'
);

our %l2p = (
  P => PAWN,
  N => KNIGHT,
  B => BISHOP,
  R => ROOK,
  Q => QUEEN,
  K => KING,

  p => OPP_PAWN,
  n => OPP_KNIGHT,
  b => OPP_BISHOP,
  r => OPP_ROOK,
  q => OPP_QUEEN,
  k => OPP_KING
);

our %p2l = (
  EMPTY, '_',

  PAWN, 'P',
  KNIGHT, 'N',
  BISHOP, 'B',
  ROOK, 'R',
  QUEEN, 'Q',
  KING, 'K',

  OOB, 'X',

  OPP_PAWN, 'p',
  OPP_KNIGHT, 'n',
  OPP_BISHOP, 'b',
  OPP_ROOK, 'r',
  OPP_QUEEN, 'q',
  OPP_KING, 'k',

  OPP_OOB, 'X'
);

1;
