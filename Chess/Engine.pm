package Chess::Engine;
use strict;
use warnings;

use Chess::Constant;
use Chess::State;

use Chess::Book;

use List::Util qw(sum max);

use constant DEBUG => 1;

# Construct a new Engine object.
#  You MUST pass in a reference to a state.
# Optionally specify a max-ply.
sub new {
  my $class = shift;

  # empty object with defaults
  my %self;
  $self{state} = shift || die "Cannot instantiate Chess::Engine without a Chess::State";
  $self{depth} = shift || 3;

  # Bless this class and return
  return bless \%self, $class;
}

# Simple evaluation function
#  Count point values for each piece on board
# Values are from the POV of White, so need invert
#  if playing Black
my %piece_values = (
  KING, 5590,
  PAWN, 10,
  BISHOP, 30,
  KNIGHT, 30,
  ROOK, 50,
  QUEEN, 90,
  OPP_KING, -5590,
  OPP_PAWN, -10,
  OPP_BISHOP, -30,
  OPP_KNIGHT, -30,
  OPP_ROOK, -50,
  OPP_QUEEN, -90,
  EMPTY, 0,
  OOB, 0,
);

# Recursive "think" that uses only board state, not self.
sub _rec_think {
  my ($state, $depth, $alpha, $beta) = @_;

  #printf("%s> _rec_think($depth, $alpha, $beta):", "===" x (3 - $depth));
  # STATIC EVALUATOR
  # bail if at the bottom
  #printf("%d\n", -sum( map { $piece_values{$_} } @{$state->[0]})) unless $depth;
  #return (-sum( map { $piece_values{$_} } @{$state->[0]}), undef) unless $depth;
  #print "\n";
  # Get all available moves
  my $best_value;
  my $best_move;
  foreach my $move (@{$state->generate_pseudo_moves})
  {
    # Attempt to make the move!
    my $new_state = $state->make_move($move);
    if (defined $new_state)
    {
      #printf("%s> Consider move: %s\n", "===" x (3 - $depth), $state->decode_move($move));
      # Move was successful.  Recurse.
      my ($value) = $depth ?
        _rec_think($new_state, $depth - 1, -$beta, -$alpha) :
        (sum( map { $piece_values{$_} } @{$state->[0]}));
      #printf("%s> Value of move %s was %d\n", "===" x (3 - $depth), $state->decode_move($move), $value);
      # Value of this move depends on whether we are at max depth or not.
      if (! defined $best_value || $best_value < $value) {
        #printf("%s> Better than best_value (%s), updating\n", "===" x (3 - $depth), defined $best_value ? $best_value : 'undef');
        $best_value = $value;
	$best_move = $move;
        # update the alpha cutoff
        $alpha = max($alpha, $best_value);
        #printf("%s> Alpha now %d\n", "===" x (3 - $depth), $alpha);
        # test against Beta
        #printf("%s> Alpha >= beta %d, SKIPPING\n", "===" x (3 - $depth), $beta) if $alpha >= $beta;
        last if $alpha >= $beta;
      }
    }
  }

  # Dead end if we didn't make any valid moves
  $best_value = ($state->is_checked() ? -99999 : 0) unless defined $best_value;

  #printf("%s> AT FINAL: return best value %d, move %s\n", "===" x (3 - $depth), $best_value, $state->decode_move($best_move));

  return (- $best_value, $best_move);
}

# Given a state,
#  return what I think is the best move.
# This is mainly a converience wrapper around rec_think.
sub think {
  my $self = shift;
  #my ($self, @move_list) = shift;

  my $state = ${$self->{state}};

  # see if we can make a book move
  my $pos = join('', map { $p2l{$_} }
    @{$state->[0]}[21 .. 28, 31 .. 38, 41 .. 48, 51 .. 58, 61 .. 68, 71 .. 78, 81 .. 88, 91 .. 98]);
  #print "THINK: " . $pos . "\n";

  my $entry = $Chess::Book::book{$pos};
  if ($entry) {
    #print "BOOK HIT\n";
    return $entry->[rand(@$entry)];
  }

  #my ($best_value, $best_move);
  #foreach $move (@move_list) {
  my ($score, $move) = _rec_think(${$self->{state}}, $self->{depth} - 1, -99999, 99999);
  return $move;
  #}
}

1;
