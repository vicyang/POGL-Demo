=info
    Auth: 523066680
    Date: 2017-07
=cut

use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;

our $SIZE_X = 500;
our $SIZE_Y = 500;
our $WinID;

&Main();

sub display
{
    glClear(GL_COLOR_BUFFER_BIT);
    my @rasters = 
        (
            (0xFF, 0xFF, 0x00, 0xFF)x10, (0xFF, 0xFF, 0xFF, 0xFF)x10,
            (0xFF, 0xFF, 0x00, 0xFF)x10, (0xFF, 0xFF, 0xFF, 0xFF)x10,
            (0xFF, 0xFF, 0x00, 0xFF)x10, (0xFF, 0xFF, 0xFF, 0xFF)x10,
            (0xFF, 0xFF, 0x00, 0xFF)x10, (0xFF, 0xFF, 0xFF, 0xFF)x10,
            (0xFF, 0xFF, 0x00, 0xFF)x10, (0xFF, 0xFF, 0xFF, 0xFF)x10,
        );

    my $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);

    glRasterPos2i(0.0, 0.0);
    glDrawPixels_c( 20, 5, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
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
