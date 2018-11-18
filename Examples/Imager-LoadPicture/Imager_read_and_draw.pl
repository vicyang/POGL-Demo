=info
    Auth: 523066680
    Date: 2017-07
=cut

use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Imager;

our $SIZE_X = 620;
our $SIZE_Y = 520;
our $WinID;

INIT
{
    my $file = "colorful.png";
    my $img = Imager->new();
    $img->read(file => $file) or die "Cannot load $file: ", $img->errstr;

    our ($H, $W) = ($img->getheight(), $img->getwidth());
    printf "width: %d, height: %d\n", $W, $H;

    our @rasters;
    my @colors;
    for my $y ( reverse 0 .. $H-1 )
    {
        @colors = $img->getpixel(x=>[ 0 .. $W-1 ], y=>[ $y ]);   
        grep { push @rasters, $_->rgba  } @colors;
    }
}

&Main();

sub display
{
    glClear(GL_COLOR_BUFFER_BIT);

    my $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);

    glRasterPos2i(-1, -1);
    glDrawPixels_c( $W, $H, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.3, 0.6, 0.8, 1.0);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

sub idle 
{
    sleep 0.1;
    glutPostRedisplay();
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
    glutIdleFunc(\&idle);
    glutMainLoop();
}
