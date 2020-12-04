#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

## LOCAL MODULES
# make local dir accessible for use statements
use FindBin qw( $RealBin );
use lib $RealBin;

use Chess::Constant;
use Chess::State;
use Chess::Engine;

# setup board
#  use default PGN
#my $state = Chess::State->new('8/3k1q2/8/8/8/3K4/1r3R2/8 w - -');
#my $state = Chess::State->new('8/3k4/8/8/8/3K4/1R3R2/8 w - -');
my $state = Chess::State->new;
# attach engine
#  maxdepth 3
my $engine = Chess::Engine->new(\$state, 4);

while ($state->is_playable)
{
  # Print board
  print "FEN: " . $state->get_fen . "\n";

  # check for check (find my king)
  #print (is_check($self->{board}) ? "IN CHECK\n" : "(not in check)\n");
  # board image, rank 8 down to 1
  my @board = $state->get_board;
  print "+-+-+-+-+-+-+-+-+\n";
  for my $rank (0 .. 7) {
    for my $file (0 .. 7) {
      my $piece = $board[7 - $rank][$file];
      printf("|%1s", $piece ? $p2l{$piece} : ' ');
    }
    printf("|%d\n", 8 - $rank);
    print "+-+-+-+-+-+-+-+-+\n";
  }
  print " a b c d e f g h\n\n";

  # list all possible moves
  print "\nAvailable moves:\n";
  foreach my $possible_move ($state->get_moves) {
    print " $possible_move\n";
  }

  my $move;
  if (! $state->[1])
  {
    # Show prompt and get input from user
    print "> ";
    my $input = <STDIN>;
    chomp $input;

    # parse move
    $move = $state->encode_move($input);
  } else {
    # Computer's turn!
    $move = $engine->think;
    #print "Thinking results: movre $score, move chain: " . join(' -> ',  @movelist) . "\n";

    print "> " . $state->decode_move($move) . "\n";
  }

  #print 'encoded: ' . join(',', map { defined $_ ? $_ : '' } @$move) . "\n";
  # Attempt to apply the move.
  my $new_state = eval { $state->make_move($move) };
  if (! defined $new_state) {
    die "Error: " . $@;
  }

  $state = $new_state;
}
