package Chess::State;
use strict;
use warnings;

###############################################################################
# BOARD STATE CLASS
###############################################################################

use Chess::Constant;

###############################################################################
# Named array keys, saves a bit of time over hash-based object
use constant 1.03 {
  BOARD => 0,
  TURN => 1,
  CASTLE => 2,
  EP => 3,
  HALFMOVE => 4,
  MOVE => 5
};
#use constant KINGS => 6;

###############################################################################
# constructor
sub new {
  my ($class, $initialFEN) = @_;

  # default position if unspecified
  $initialFEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    unless $initialFEN;

  # empty object with defaults
  my @self;

  # Apply initial FEN to set board position / state
  set_fen(\@self, $initialFEN);

  # Bless this class and return
  return bless \@self, $class;
}

###############################################################################
# FEN Operations
#  Forsyth-Edwards Notation is essentially the "serialization format"
#  for the State class
###############################################################################
# Parse a FEN string and replace internal state with it
sub set_fen {
  my ($self, $input) = @_;

  # Regex to match FEN and identify components
  die "Invalid FEN string '$input'" unless $input =~ m{^\s*([BKNPQR1-8/]+)\s+([BW])\s+([KQ]+|-)\s+((?:[A-H][1-8])|-)\s+(\d+)\s+(\d+)\s*$}i;

  # a new FEN position always deletes all history
  #$self->{history} = [];

  # Unpack each component into the internal state
  #  Whose turn?
  $self->[TURN] = lc($2) eq 'b';

  #  Castling ability
  $self->[CASTLE] = [ [], [] ];
  $self->[CASTLE][$self->[TURN]][CASTLE_KING] = index($3, 'K') >= 0;
  $self->[CASTLE][$self->[TURN]][CASTLE_QUEEN] = index($3, 'Q') >= 0;
  $self->[CASTLE][! $self->[TURN]][CASTLE_KING] = index($3, 'k') >= 0;
  $self->[CASTLE][! $self->[TURN]][CASTLE_QUEEN] = index($3, 'q') >= 0;

  #  EP
  $self->[EP] = $4 eq '-' ? undef : $4;
  #  Halfmove clock
  $self->[HALFMOVE] = $5;
  #  Move number
  $self->[MOVE] = $6;

  #  Board
  $self->[BOARD] = [
    OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB,
    OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, OOB,
    OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB,
    OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB, OOB
  ];

  #$self->[KINGS] = [];

  # Fill board with proper piece positions
  #  FEN works back-to-fore
  my $rank = 90;
  foreach my $row (split /\//, $1, 8)
  {
    my $file = 1;
    foreach my $code (split //, $row) {
      # Is a piece value
      if ($code =~ m/^[BKNPQRbknpqr]$/)
      {
        # flip board and value if Black perspective
	if ($self->[TURN]) {
	  my $piece = -$l2p{$code};
          $self->[BOARD][110 - $rank + $file] = $piece;
	  #$self->[KINGS][1] = 110 - $rank + $file if $piece == KING;
	  #$self->[KINGS][0] = 110 - $rank + $file if $piece == OPP_KING;
	} else {
	  my $piece = $l2p{$code};
          $self->[BOARD][$rank + $file] = $piece;
	  #$self->[KINGS][0] = $rank + $file if $piece == KING;
	  #$self->[KINGS][1] = $rank + $file if $piece == OPP_KING;
	}

        # Next square
        $file ++;
      } elsif ($code =~ m/^[1-8]$/) {
        # "Skip" (digit, just advance)
        $file += $code;
      } else {
        die "Illegal character $code in FEN string";
      }
    }
    # skip border
    $rank -= 10;
  }
}

###############################################################################
# Return a FEN string representing the current game state
sub get_fen {
  my ($self) = @_;

  # Returns the board-state in FEN notation
  my $placement = '';

  # FEN is always from White perspective, so
  #  un-flip if it is stored as Black's turn
  for my $rank (0 .. 7)
  {
    my $skip = 0;
    # Scan across file left-right
    for my $file (0 .. 7) {
      my $piece = $self->[TURN] ?
        -$self->[BOARD][10 * (2 + $rank) + $file + 1] :
	$self->[BOARD][10 * (9 - $rank) + $file + 1];

      if ($piece) {
        # Indicate a piece at this location.  If we had stepped over any, indicate spacing.
        if ($skip > 0) {
          $placement .= $skip;
          $skip = 0;
        }
        $placement .= $p2l{$piece};
      } else {
        $skip ++;
      }
    }
    if ($skip > 0) {
      # Pad remaining squares
      $placement .= $skip;
    }
    if ($rank < 7) {
      # Rank delimiter
      $placement .= '/';
    }
  }

  # Castle
  my $castle = '';;
  $castle .= 'K' if $self->[CASTLE][$self->[TURN]][CASTLE_KING];
  $castle .= 'Q' if $self->[CASTLE][$self->[TURN]][CASTLE_QUEEN];
  $castle .= 'k' if $self->[CASTLE][! $self->[TURN]][CASTLE_KING];
  $castle .= 'q' if $self->[CASTLE][! $self->[TURN]][CASTLE_QUEEN];
  $castle = '-' if $castle eq '';

  # EP
  my $ep;
  #if (defined $self->[EP]) {
  #  $ep = $idx2sqr($self->[EP]);
  #} else {
    $ep = '-';
  #}

  return join(' ',
    $placement,
    ($self->[TURN] ? 'b' : 'w'),
    $castle,
    $ep,
    $self->[HALFMOVE],
    $self->[MOVE]
  );
}

###############################################################################
# ACCESSORS
#  these provide game same info in a "white-perspective" form
#  perhaps useful for printing or playing
###############################################################################
# get board
sub get_board
{
  my ($self) = @_;

  my @ret;
  for my $rank (20, 30, 40, 50, 60, 70, 80, 90) {
    if ($self->[TURN]) {
      push @ret, [ map { - $_ } @{$self->[BOARD]}[110-$rank+1 .. 110-$rank+8] ];
    } else {
      push @ret, [ @{$self->[BOARD]}[$rank+1 .. $rank+8] ];
    }
  }
  return @ret;
}

###############################################################################
# get moves (stringified)
sub get_moves
{
  my ($self) = @_;

  return map { decode_move($self, $_) } generate_moves($self);
}

# converts a string to a move array
sub encode_move
{
  my ($self, $move) = @_;
  my @fields = split //, $move;

  if ($self->[TURN])
  {
    return [
      10 * (10 - $fields[1]) + ord($fields[0]) - ord('a') + 1,
      10 * (10 - $fields[3]) + ord($fields[2]) - ord('a') + 1,
      ($fields[4] ? - $p2l{$fields[4]} : undef)
    ];
  }

  return [
    10 * ($fields[1] + 1) + ord($fields[0]) - ord('a') + 1,
    10 * ($fields[3] + 1) + ord($fields[2]) - ord('a') + 1,
    ($fields[4] ? $p2l{$fields[4]} : undef)
  ];
}

# converts a move array back to a string
sub decode_move
{
  my ($self, $move) = @_;

  if ($self->[TURN])
  {
    return sprintf('%c%1d%c%1d%s',
      ($move->[0] % 10) - 1 + ord 'a',
      10 - int($move->[0] / 10),
      ($move->[1] % 10) - 1 + ord 'a',
      10 - int($move->[1] / 10),
      ($move->[2] ? $l2p{$move->[2]} : ''));
  }

  return sprintf('%c%1d%c%1d%s',
    ($move->[0] % 10) - 1 + ord 'a',
    int($move->[0] / 10) - 1,
    ($move->[1] % 10) - 1 + ord 'a',
    int($move->[1] / 10) - 1,
    ($move->[2] ? $l2p{$move->[2]} : ''));
}

###############################################################################
# INTERACTION
###############################################################################
# Make Move - does NOT look for post-move check
#  moves should be (from_idx, to_idx, promotion_piece)
sub make_move {
  my ($self, $move) = @_;

  # Construct a new board by duplicating the old - flip vertical and invert values
  #  Board
  my @board = @{$self->[BOARD]};

  # lookup the existing piece
  my $from_piece = $board[$move->[0]];
  # make move
  if (defined $move->[3]) {
    # special-case handler
    if ($move->[3] == CASTLE_KING) {
      # kingside castle
      # cannot castle out of check
      return undef if checked(\@board);
      #  test move-through-check
      @board[25, 26] = (0, KING);
      return undef if checked(\@board);
      # move rook
      @board[28, 26] = (0, ROOK);
      # fall through to next condition (king move)
    } elsif ($move->[3] == CASTLE_QUEEN) {
      # queenside castle
      # cannot castle out of check
      return undef if checked(\@board);
      #  test move-through-check
      @board[25, 24] = (0, KING);
      return undef if checked(\@board);
      # move rook
      @board[21, 24] = (0, ROOK);
      # fall through to next condition (king move)
    }
  }

  @board[$move->[0], $move->[1]] = (0, $move->[2] || $from_piece);

  # Test for legality.
  return undef if checked(\@board);

  # flip board
  for my $rank (20, 30, 40, 50) {
    ($board[$rank + $_], $board[110 - $rank + $_]) = (-$board[110 - $rank + $_], -$board[$rank + $_]) for (1 .. 8);
  }

  # A new State object, holds the updated board... and flip the turn.
  # this is a wild performance hack that works because new_state is an array
  return bless [
    \@board,
    ! $self->[TURN],
  # TODO
    [ $self->[CASTLE][1], [
      $move->[0] == 25 || $move->[0] == 28 ? 0 : $self->[CASTLE][0][CASTLE_KING],
      $move->[0] == 25 || $move->[0] == 21 ? 0 : $self->[CASTLE][0][CASTLE_QUEEN] ] ],
  # TODO
    (defined $self->[EP] ? $self->[EP] : undef),
    (($from_piece == PAWN || defined $move->[2]) ?  0 : $self->[HALFMOVE] + 1),
    ($self->[TURN] ? $self->[MOVE] + 1 : $self->[MOVE]),
    #[ $self->[KINGS][1], $self->[KINGS][0] ]
  ];

  # Bless this class and return
  #return bless \@new_state; #, ref $self;
}

###############################################################################
# Get move list, from current perspective - FILTERED by movement into check
sub generate_moves
{
  my ($self) = @_;

  # locate king
  return grep {
    defined make_move($self, $_);
  } @{generate_pseudo_moves($self)};
}

sub is_checked {
  return checked($_[0]->[BOARD]);
}

sub is_playable {
  return (generate_moves($_[0]) > 0);
}

###############################################################################
# A helper function for determining Check: returns true if
#  the enemy King is in check.
sub checked
{
  my ($board) = @_;

  for (21 .. 28, 31 .. 38, 41 .. 48, 51 .. 58, 61 .. 68, 71 .. 78, 81 .. 88, 91 .. 98) {
    return attacked($board, $_) if $board->[$_] == KING
  }
}

###############################################################################
# MOVE GENERATION
###############################################################################
# Given a board and a square, determine if the square is
#  attacked by current player.
sub attacked {
  my ($board, $idx) = @_;

  # check surrounding squares (pawn, queen, bishop, rook, king attack)
  for (-11, -10, -9, -1, 1, 9, 10, 11) {
    return 1 if $board->[$idx + $_] == OPP_KING;
  }

  return 1 if $board->[$idx - 11] == OPP_PAWN ||
              $board->[$idx - 9] == OPP_PAWN;

  # check knight attacks from here
  for (-21, -19, -12, -8, 8, 12, 19, 21) {
    return 1 if $board->[$idx + $_] == OPP_KNIGHT;
  }

  # more distant attacks
  # check if attack by rook or queen
  my $dest;
  for my $inc (-10, -1, 1, 10) {
    $dest = $idx;
    do {
      $dest += $inc;
      return 1 if $board->[$dest] == OPP_ROOK ||
                  $board->[$dest] == OPP_QUEEN;
    } while (! $board->[$dest] );
  }

  # now bishop or queen
  for my $inc (-11, -9, 9, 11) {
    $dest = $idx;
    do {
      $dest += $inc;
      return 1 if $board->[$dest] == OPP_BISHOP ||
                  $board->[$dest] == OPP_QUEEN;
    } while (! $board->[$dest] );
  }

  # square is safe...
  return 0;
}

###############################################################################
# Get move list - UNfiltered by movement into check
sub generate_pseudo_moves
{
  my ($self) = @_;

  #my @board = \@{$self->[BOARD]};

  # Begin with an empty list of potential moves.
  my @m;

  # Iterate through each piece on the board.
  #for my $idx (21 .. 98) {
  for my $idx (21 .. 28, 31 .. 38, 41 .. 48, 51 .. 58, 61 .. 68, 71 .. 78, 81 .. 88, 91 .. 98) {
    # only do something if it's white piece
    #next unless $self->[BOARD][$idx] > 0 && $self->[BOARD][$idx] < OOB;

    # Compute all possible moves.
    if ($self->[BOARD][$idx] == KING) {
      # King can move to one of 8 directions, as long as
      #  it does not step out of bounds, and does not step on a friendly piece.
      for (-11, -10, -9, -1, 1, 9, 10, 11) {
        push @m, [ $idx, $idx + $_ ] if $self->[BOARD][$idx + $_] <= 0;
      }
    } elsif ($self->[BOARD][$idx] == KNIGHT) {
      # Knight
      for (-21, -19, -12, -8, 8, 12, 19, 21) {
        push @m, [ $idx, $idx + $_ ] if $self->[BOARD][$idx + $_] <= 0;
      }
    } elsif ($self->[BOARD][$idx] == PAWN) {
      # Pawn
      #  Attempt a one-space-forward move
      if (! $self->[BOARD][$idx + 10]) {
        if ($idx > 90) {
          # end of board for white!  Promote.
          push @m,
              [ $idx, $idx + 10, BISHOP ],
              [ $idx, $idx + 10, KNIGHT ],
              [ $idx, $idx + 10, QUEEN ],
              [ $idx, $idx + 10, ROOK ];
        } else {
          push @m, [ $idx, $idx + 10 ];

          # we may double-push if on 2nd rank and 4th unoccupied
          if ($idx < 40 && ! $self->[BOARD][$idx + 20])
          {
            # TODO: log EP?
            push @m, [ $idx, $idx + 20 ];
          }
        }
      }

      # Try a capture instead.
      for (9, 11)
      {
        # TODO: EP

        # check ownership by opponent.
        if ($self->[BOARD][$idx + $_] < 0) {
          if ($idx > 90) {
            # end of board for white!  Promote.
            push @m,
                [ $idx, $idx + $_, BISHOP ],
                [ $idx, $idx + $_, KNIGHT ],
                [ $idx, $idx + $_, QUEEN ],
                [ $idx, $idx + $_, ROOK ];
          } else {
            push @m, [ $idx, $idx + $_ ];
          }
        }
      }
    } else {
      # Rook, Bishop, or Queen moves

      # Rook or Queen moves
      if ($self->[BOARD][$idx] == ROOK || $self->[BOARD][$idx] == QUEEN) {
        for my $inc (-10, -1, 1, 10) {
          my $dest = $idx;
          do {
            $dest += $inc;
            push @m, [ $idx, $dest ] if $self->[BOARD][$dest] <= 0;
          } while ( ! $self->[BOARD][$dest] );
        }
      }

      # Bishop or Queen moves
      if ($self->[BOARD][$idx] == BISHOP || $self->[BOARD][$idx] == QUEEN) {
        for my $inc (-11, -9, 9, 11) {
          my $dest = $idx;
          do {
            $dest += $inc;
            push @m, [ $idx, $dest ] if $self->[BOARD][$dest] <= 0;
          } while ( ! $self->[BOARD][$dest] );
        }
      }
    }
  }

  # Castling
  push @m, [ 25, 27, undef, CASTLE_KING ] if $self->[CASTLE][0][CASTLE_KING] && $self->[BOARD][26] == EMPTY && $self->[BOARD][27] == EMPTY;
  push @m, [ 25, 23, undef, CASTLE_QUEEN ] if $self->[CASTLE][0][CASTLE_QUEEN] && $self->[BOARD][24] == EMPTY && $self->[BOARD][23] == EMPTY && $self->[BOARD][22] == EMPTY;

  return \@m;
}

###############################################################################
# DEBUG - Pretty-print a Board and other internal state.
#  This is formatted *as the engine sees it*
sub pp {
  my ($self) = @_;

  # header
  print "FEN: " . $self->get_fen . "\n";

  # check for check (find my king)
  print (checked($self->[BOARD]) ? "IN CHECK\n" : "(not in check)\n");
  # board image, rank 8 down to 1
  print "TURN: " . ($self->[TURN] ? '1 - BLACK' : '0 - WHITE') . "\n";
  print "   0 1 2 3 4 5 6 7 8 9\n";
  print "  +-+-+-+-+-+-+-+-+-+-+\n";
  for my $rank (0 .. 11) {
    printf("%2d|", $rank);
    for my $file (0 .. 9) {
      my $piece = $self->[BOARD][10 * $rank + $file];
      printf("%1s|", $piece ? $p2l{$piece} : ' ');
    }
    print "\n  +-+-+-+-+-+-+-+-+-+-+\n";
  }
  print "\n";

  # other state info
  print "Castle: self, K=" . $self->[CASTLE][$self->[TURN]][CASTLE_KING] . ', Q=' . $self->[CASTLE][$self->[TURN]][CASTLE_QUEEN] . "\n";
  print "    opponent, k=" . $self->[CASTLE][! $self->[TURN]][CASTLE_KING] . ', q=' . $self->[CASTLE][! $self->[TURN]][CASTLE_QUEEN] . "\n";
  print "En Passant: " . ($self->[EP] ? join(',', @{$self->[EP]}) : '(none)') . "\n";
  print "Halfmove: " . $self->[HALFMOVE] . "\n";
  print "Move: " . $self->[MOVE] . "\n";

  # list all possible moves
  print "\nAvailable moves:\n";
  foreach my $move (@{$self->generate_pseudo_moves}) {
    print " [" . join(',', @{$move}) . "]";
    print " (moves into check)" unless defined $self->make_move($move);
    print "\n";
  }
}

1;
