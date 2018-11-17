=info
    Auth: 523066680
    Date: 2018-11
=cut

use utf8;
use Encode;
use feature 'state';
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Data::Dumper;
use Imager;
STDOUT->autoflush(1);

our $SIZE_X = 620;
our $SIZE_Y = 520;
our $WinID;

INIT
{
    use Imager;
    our $SIZE = 30;
    our $font = Imager::Font->new(file  => 'C:/windows/fonts/STXINGKA.TTF',
                              size  => $SIZE );

        #glRasterPos3f( $id * $SIZE/1.2, 20.0, 0.0 );
        #glDrawPixels_c( $W, $H, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );
}

our @TEXT = split("", "十步杀一人，千里不留行。事了拂衣去，深藏身与名。" );
our @TEXT_DATA = map { {} } ( 0 .. $#TEXT );

for my $id ( 0 .. $#TEXT )
{
    get_text_map( $TEXT[$id] , $TEXT_DATA[$id] );
    printf "%d %d\n", $TEXT_DATA[$id]->{h}, $TEXT_DATA[$id]->{w};
}


Main();

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->total_width, ysize=>$SIZE, channels=>4);

    $img->string(
               font  => $font,
               text  => $char,
               x     => -$bbox->left_bearing,
               y     => 0 + $SIZE + $bbox->descent,     #基线偏移
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
            );
    my $h = $img->getheight();
    my $w = $img->getwidth();
    $ref->{h} = $h, $ref->{w} = $w;

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $h - 1 )
    {
        @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
        grep { push @rasters, $_->rgba  } @colors;
    }

    $ref->{array} = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $ref->{array}->assign(0, @rasters);
}

sub display
{
    state $iter = 0;
    my $xbase = 0.0;
    my $ybase = 50.0;
    glClear(GL_COLOR_BUFFER_BIT);

    my $ref;
    for my $id ( 0 .. $iter )
    {
        $ref = $TEXT_DATA[ $id ];
        glRasterPos3f( $xbase , $ybase, 0.0 );
        glDrawPixels_c( $ref->{w}, $ref->{h}, GL_RGBA, GL_UNSIGNED_BYTE, $ref->{array}->ptr() );
        $xbase += $SIZE;
        if ( $TEXT[$id] eq "。" ) { $ybase -= $SIZE, $xbase = 0.0 }
    }

    $iter ++ if $iter < $#TEXT;

    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.3, 0.6, 0.8, 1.0);
    
    # 通过开启混合，来避免位图的透明背景变黑问题
    glEnable(GL_BLEND);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

sub idle 
{
    sleep 0.1;
    glutPostRedisplay();
}

sub reshape 
{
    my ($w, $h) = (shift, shift);
    #Same with screen size
    my $hz_half = $w/2.0;
    my $vt_half = $h/2.0;
    my $fa = 10.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho( 0.0, $h, 0.0, $w, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    my $key = shift;
    glutDestroyWindow($WinID) if ( lc(chr($key)) eq 'q' );
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("glBitmap");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
