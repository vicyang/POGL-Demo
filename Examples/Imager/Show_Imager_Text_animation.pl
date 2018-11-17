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
    our $SIZE = 60;
    our $font = Imager::Font->new(file  => 'C:/windows/fonts/STXINGKA.TTF',
                              size  => $SIZE );


    our $TEXT = "天之道，损有余而补不足。";
    our @TEXT = split("", $TEXT);
    our @TEXT_BUFF;
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

    my ($H, $W) = ($img->getheight(), $img->getwidth());
    #printf "width: %d, height: %d\n", $W, $H;

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $H-1 )
    {
        @colors = $img->getpixel( x => [ 0 .. $W-1 ], y => [$y] );
        grep { push @rasters, $_->rgba  } @colors;
    }
    #print Dumper $$ref, "\n";

    $$ref = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    ${$ref}->assign(0, @rasters);

    return ($H, $W);
}

sub display
{
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT);

    # my $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    # $array->assign(0, @rasters);


    my ($H, $W, $array);
    glRasterPos3f( 0.0, 20.0, 0.0 );
    for my $id ( 0 .. $iter )
    {
        ($H, $W) = get_text_map( $TEXT[$id] , \$array);
        glRasterPos3f( $id * $SIZE/1.2, 20.0, 0.0 );
        glDrawPixels_c( $W, $H, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );
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
