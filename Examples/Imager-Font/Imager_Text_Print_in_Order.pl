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
our $pause = 0;

INIT
{
    our $SIZE = 26;
    our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/Consola.ttf'), #STXINGKA.TTF
                                  size  => $SIZE );
    our $bbox = $font->bounding_box( string => "a" );
    our $img = Imager->new(xsize=>400, ysize=>400, channels=>4);
    our $ybase = 0.0;

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
            filled => 1, color => '#336699');

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $h - 1 )
    {
        @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
        grep { push @rasters, $_->rgba  } @colors;
    }

    our $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);

    our @TEXT = ();
}

Main();

sub update_text
{
    our ($font, $SIZE, $img, $array, $ybase, $bbox);
    my ( $string ) = @_;

    my $h = $img->getheight();
    my $w = $img->getwidth();
    $ybase += $bbox->font_height;

    $img->string(
               font  => $font,
               text  => $string,
               x     => 0,
               y     => $ybase,
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
            );
    
    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $h - 1 )
    {
        @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
        grep { push @rasters, $_->rgba  } @colors;
    }

    $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);
}

sub display
{
    our ($bbox, $array, $img);
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT);

    glRasterPos3f( 20.0, 20.0, 0.0 );
    glDrawPixels_c( $img->getwidth, $img->getheight, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

    update_text(join( "", map { ('a'..'z', 'A'..'E')[rand(31)] } ( 1 .. rand(10)+2 ))  );

    $iter ++ if ( $pause == 0);
    glutSwapBuffers();
}

sub init 
{
    srand(1);
    glClearColor(0.3, 0.6, 0.8, 1.0);
    
    # 通过开启混合，来避免位图的透明背景变黑问题
    glEnable(GL_BLEND);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

sub idle 
{
    sleep 0.2;
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
    glOrtho( 0.0, $w, 0.0, $h, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    my $key = shift;
    glutDestroyWindow($WinID) if ( lc(chr($key)) eq 'q' );
    if ( chr($key) eq 'p' ) { $pause = !$pause; }
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(5, 100);
    our $WinID = glutCreateWindow("Imager::Font");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
