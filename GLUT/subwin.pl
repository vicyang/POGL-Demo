=info
    POGL Demo - Multi Viewport
    Auth: 523066680
    Date: 2017-10
    https://github.com/vicyang/Perl-OpenGL
=cut

use IO::Handle;
use Time::HiRes qw/sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use feature 'state';

STDOUT->autoflush(1);

BEGIN
{
    our $MAIN;
    our $SUB1;
    our $SUB2;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
}

&main();


MAIN:
{
    sub display
    {
        glClear( GL_COLOR_BUFFER_BIT );
        glColor4f(0.8, 0.8, 0.8, 0.5);
        glRectf(0.0, 0.0, 500.0, 500.0);
        glutSwapBuffers();
    }

    sub idle 
    {
        sleep 0.02;
        glutPostRedisplay();
    }
}

SUB1:


sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
}

sub reshape
{
    my ($w, $h) = (shift, shift);
    state $fa = 100.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-100.0, 100.0, -100.0,100.0, 0.0, $fa*2.0); 
    #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}


sub hitkey 
{
    our $WinID;
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
}

sub quit
{
    glutDestroyWindow( $MAIN );
    glutDestroyWindow( $SUB1 );
    exit 0;
}

sub main
{
    our $MAIN;

    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $MAIN = glutCreateWindow("SubWindow");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);

    our $WinID1 = glutCreateSubWindow( $MainID, 10, 10, 100, 100 );
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);

    glutMainLoop();
}

