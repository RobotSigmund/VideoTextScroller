#!c:/perl/bin/perl.exe

use Image::Magick;
use strict;

$| = 1;



# Get text
open(my $FILE, '<', 'text.txt');
our @CFG_TEXT = <$FILE>;
close($FILE);

our $CFG_CHAR_SPACING = 25; # pixels bethween letters on each line
our $CFG_LINE_SPACING = 60; # pixels between lines
our $CFG_FPS = 60; # TARGET FPS
our $CFG_FONT = "Turnpike";
our $CFG_FONT_SIZE = 35;
our $CFG_SPEED = 100; # scroll will move upwards pixels per second
our $CFG_FRAME_SIZE_X = 1920;
our $CFG_FRAME_SIZE_Y = 1080;

# Add sin angle for x character position every second
our $CFG_SPEED_MOVE_X1 = -1;
our $CFG_SPEED_MOVE_X2 = 2.2;
our $CFG_SPEED_MOVE_Y1 = 1.1;
our $CFG_SPEED_MOVE_Y2 = 2.1;

# Add sin angle for y line position every second
our $CFG_SPEED_LINE_MOVE_X1 = -1.25;
our $CFG_SPEED_LINE_MOVE_X2 = 1.9;
our $CFG_SPEED_LINE_MOVE_Y1 = 1.175;
our $CFG_SPEED_LINE_MOVE_Y2 = 2.025;

# Add sin angle per character in x direction (on each line)
our $CFG_SPEED_ADD_X1 = 0.15;
our $CFG_SPEED_ADD_X2 = 0.13;
our $CFG_SPEED_ADD_Y1 = 0.16;
our $CFG_SPEED_ADD_Y2 = 0.11;

# Add sin angle per line
our $CFG_SPEED_LINE_ADD_X1 = 0.17;
our $CFG_SPEED_LINE_ADD_X2 = -0.105;
our $CFG_SPEED_LINE_ADD_Y1 = 0.175;
our $CFG_SPEED_LINE_ADD_Y2 = 0.07;

# add offset per sin angle
our $CFG_SPEED_SIZE_X1 = 36;
our $CFG_SPEED_SIZE_X2 = 28;
our $CFG_SPEED_SIZE_Y1 = 25;
our $CFG_SPEED_SIZE_Y2 = 9;



# Create canvas template, we will dupe this for each frame and use for background
my $canvas_template = Image::Magick->new;
$canvas_template->Set(size=>$CFG_FRAME_SIZE_X . 'x' . $CFG_FRAME_SIZE_Y);
$canvas_template->ReadImage('canvas:green');

my $framecount = 0;
my $pos_x_sin1 = rand();
my $pos_x_sin2 = rand();
my $pos_y_sin1 = rand();
my $pos_y_sin2 = rand();
my $line_x_sin1 = rand();
my $line_x_sin2 = rand();
my $line_y_sin1 = rand();
my $line_y_sin2 = rand();


mkdir('img') unless (-e 'img') or die('Can not create "img" folder');

# Figure out finish line
my $framecount_finish = 1;
$framecount_finish++ while (($CFG_FRAME_SIZE_Y - ($framecount_finish * $CFG_SPEED / $CFG_FPS) + (($#CFG_TEXT + 1) * $CFG_LINE_SPACING) + Max(($CFG_SPEED_SIZE_X1, $CFG_SPEED_SIZE_X2, $CFG_SPEED_SIZE_Y1, $CFG_SPEED_SIZE_Y2))) >= 0);

while (1) {
	print 'Working on frame ' . $framecount . '/' . $framecount_finish . ' ' . int($framecount / $framecount_finish * 100) . '%...';
	generate_frame($framecount, \$canvas_template, $pos_x_sin1, $pos_x_sin2, $pos_y_sin1, $pos_y_sin2, $line_x_sin1, $line_x_sin2, $line_y_sin1, $line_y_sin2);
	print 'ok' . "\n";
	
	$pos_x_sin1 += $CFG_SPEED_MOVE_X1 / $CFG_FPS;
	$pos_x_sin2 += $CFG_SPEED_MOVE_X2 / $CFG_FPS;
	$pos_y_sin1 += $CFG_SPEED_MOVE_Y1 / $CFG_FPS;
	$pos_y_sin2 += $CFG_SPEED_MOVE_Y2 / $CFG_FPS;
	$line_x_sin1 += $CFG_SPEED_LINE_MOVE_X1 / $CFG_FPS;
	$line_x_sin2 += $CFG_SPEED_LINE_MOVE_X2 / $CFG_FPS;
	$line_y_sin1 += $CFG_SPEED_LINE_MOVE_Y1 / $CFG_FPS;
	$line_y_sin2 += $CFG_SPEED_LINE_MOVE_Y2 / $CFG_FPS;

	# Should we exit, check if last line is above 0
	last if (($CFG_FRAME_SIZE_Y - ($framecount * $CFG_SPEED / $CFG_FPS) + (($#CFG_TEXT + 1) * $CFG_LINE_SPACING) + Max(($CFG_SPEED_SIZE_X1, $CFG_SPEED_SIZE_X2, $CFG_SPEED_SIZE_Y1, $CFG_SPEED_SIZE_Y2))) < 0);

	$framecount++;
}

exit;



sub generate_frame {
	my($frame_i, $canvas_template_ref, $xsin1, $xsin2, $ysin1, $ysin2, $lxsin1, $lxsin2, $lysin1, $lysin2,) = @_;
	
	my $image = Image::Magick->new;
	$image = $$canvas_template_ref->Clone();

	my $y_position_start = $CFG_FRAME_SIZE_Y + $CFG_FONT_SIZE + Max(($CFG_SPEED_SIZE_X1, $CFG_SPEED_SIZE_X2, $CFG_SPEED_SIZE_Y1, $CFG_SPEED_SIZE_Y2)) - ($frame_i * ($CFG_SPEED / $CFG_FPS));
	
	# Loop through all lines
	foreach my $line_i (0..$#CFG_TEXT) {
		my $line_text = $CFG_TEXT[$line_i];
		my $x_position_center = ($CFG_FRAME_SIZE_X / 2);
		
		my $xsin1_line = $lxsin1 + ($CFG_SPEED_LINE_ADD_X1 * $line_i);
		my $xsin2_line = $lxsin2 + ($CFG_SPEED_LINE_ADD_X2 * $line_i);
		my $ysin1_line = $lysin1 + ($CFG_SPEED_LINE_ADD_Y1 * $line_i);
		my $ysin2_line = $lysin2 + ($CFG_SPEED_LINE_ADD_Y2 * $line_i);

		# Loop through all chars on each line
		foreach my $char_i (0..length($line_text)) {
			
			my $xpos = $x_position_center + (($char_i - (length($line_text) / 2)) * $CFG_CHAR_SPACING);			
			my $ypos = $y_position_start + ($line_i * $CFG_LINE_SPACING);
			
			my $char_center_i = $char_i - (length($line_text) / 2);
			$xpos += sin($xsin1_line + ($CFG_SPEED_ADD_X1 * $char_center_i)) * $CFG_SPEED_SIZE_X1;
			$xpos += sin($xsin2_line + ($CFG_SPEED_ADD_X2 * $char_center_i)) * $CFG_SPEED_SIZE_X2;
			
			$ypos += sin($ysin1_line + ($CFG_SPEED_ADD_Y1 * $char_center_i)) * $CFG_SPEED_SIZE_Y1;
			$ypos += sin($ysin2_line + ($CFG_SPEED_ADD_Y2 * $char_center_i)) * $CFG_SPEED_SIZE_Y2;
			
			# outside frame?
			next if (($xpos + $CFG_FONT_SIZE) < 0);
			next if ($xpos > $CFG_FRAME_SIZE_X);
			next if ($ypos < 0);
			next if (($ypos - $CFG_FONT_SIZE) > $CFG_FRAME_SIZE_Y);
			
			# non-text character
			next if (substr($line_text, $char_i, 1) eq ' ');

			# Write one char into the image
			$image->Annotate(font=>$CFG_FONT, align=>'center', pointsize=>$CFG_FONT_SIZE, fill=>'white', stroke=>'black', strokewidth=>2, text=>substr($line_text, $char_i, 1), x=>int($xpos), y=>int($ypos));
		}
	}
	
	# Save frame
	$image->Write(filename=>sprintf("img/image%06d.jpg", $frame_i));
}



sub Max {
	my(@values) = @_;
	
	my $max = $values[0];
	
	foreach my $v (@values) {
		$max = $v if ($v > $max);
	}
	
	return $max;
}


