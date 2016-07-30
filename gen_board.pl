#/bin/perl
use strict;
use warnings;

# Output the SVG of a Chutes and Ladders Board of Traditional layout

# Calculate x coord of a gamesquare
sub find_x_coord
{
  my ($num) = @_;
  return int(($num - 1) / 10) % 2
         ?  9.5 - (($num - 1) % 10)
         : 0.5 + (($num - 1) % 10);
}

# calculate y coord of a game square
sub find_y_coord
{
  my ($num) = @_;
  return 9.5-int(($num - 1) / 10);
}

# output a SVG code for an engraved line from one point to another
sub engrave_line
{
  my ($start_x, $start_y, $fin_x, $fin_y) = @_;
  print "<polyline class=\"engrave\" points=\"$start_x,$start_y"
    ." $fin_x,$fin_y\" />\n";
}

sub add_snake
{
  my ($head, $tail) = @_;
  engrave_line(find_x_coord($head), find_y_coord($head)
               , find_x_coord($tail), find_y_coord($tail));
}

sub draw_rung
{
  my ($x_loc, $y_loc, $vect_x, $vect_y, $scaling) = @_;
  engrave_line($x_loc+$vect_y*$scaling, $y_loc-$vect_x*$scaling,
               $x_loc-$vect_y*$scaling, $y_loc+$vect_x*$scaling);
}

sub add_ladder
{
  my ($foot, $head) = @_;

  # calculate a vector perpendicular to line from $foot to $head
  my $diff_x = find_x_coord($head) - find_x_coord($foot);
  my $diff_y = find_y_coord($head) - find_y_coord($foot);
  my $length_vect = sqrt($diff_x * $diff_x + $diff_y * $diff_y);
  my $vect_x = $diff_x / $length_vect;
  my $vect_y = $diff_y / $length_vect;
  my $ladder_vert_displace=0.15;
  engrave_line(find_x_coord($foot)+$vect_y*$ladder_vert_displace,
               find_y_coord($foot)-$vect_x*$ladder_vert_displace,
               find_x_coord($head)+$vect_y*$ladder_vert_displace,
               find_y_coord($head)-$vect_x*$ladder_vert_displace);
  engrave_line(find_x_coord($foot)-$vect_y*$ladder_vert_displace,
               find_y_coord($foot)+$vect_x*$ladder_vert_displace,
               find_x_coord($head)-$vect_y*$ladder_vert_displace,
               find_y_coord($head)+$vect_x*$ladder_vert_displace);
  foreach my $this_rung (1..int($length_vect/$ladder_vert_displace/2+0.5))
    {
      draw_rung(find_x_coord($foot)+2*$ladder_vert_displace*($this_rung-0.5)*$vect_x,
                find_y_coord($foot)+2*$ladder_vert_displace*($this_rung-0.5)*$vect_y,
                $vect_x, $vect_y, $ladder_vert_displace);
    }
}

# Output SVG Header
print << 'THE_END';
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   viewBox = "-0.1 -0.1 10.1 10.1"
   version = "1.1"
   width = "360mm"
   height = "360mm"
  >
  <style type="text/css"><![CDATA[
    .cut { fill:none; stroke:red; stroke-width:0.02 }
    .engrave { fill:none; stroke:blue; stroke-width:0.02 }
    .label { font-size:3.5%; stroke:blue; stroke-width:0.02; fill:none;
             text-anchor:middle;dominant-baseline:middle;
             font-family:Arial, Helvetica, sans-serif }
  ]]></style>
THE_END

# Output the Cut on the outside
print "<rect class=\"cut\" x=\"0\" y=\"0\" width=\"10\" height=\"10\" />\n";

# Fill in the Grid
##horizontal lines
foreach my $this_horiz (1..9)
  {
    engrave_line(0, $this_horiz, 10, $this_horiz);
  }
##vertical lines
foreach my $this_vert (1..9)
  {
    engrave_line($this_vert, 0, $this_vert, 10);
  }

## numbers
foreach my $this_number (1..100)
  {
    print "<text class=\"label\" x=\"".(find_x_coord($this_number))."\"".
          " y=\"".find_y_coord($this_number)."\">"
          .$this_number."</text>\n";
  }

# Add the Snakes
add_snake(98, 78);
add_snake(95, 75);
add_snake(93, 73);
add_snake(87, 24);
add_snake(64, 60);
add_snake(62, 19);
add_snake(56, 53);
add_snake(49, 11);
add_snake(48, 26);
add_snake(16,  6);

# Add in the Chutes
add_ladder( 1, 38);
add_ladder( 4, 14);
add_ladder( 9, 31);
add_ladder(21, 42);
add_ladder(28, 84);
add_ladder(36, 44);
add_ladder(51, 67);
add_ladder(71, 91);
add_ladder(80, 100);
# Output the SVG Tail
print << 'THE_END';
</svg>
THE_END
