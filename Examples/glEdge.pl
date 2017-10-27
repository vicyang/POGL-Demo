use feature 'state';
use IO::Handle;
use Time::HiRes qw/sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
}

&main();

sub display
{
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glColor4f(0.8, 0.8, 0.8, 0.5);

    '//  not finish  //';

    glutSwapBuffers();
}

sub idle 
{
    sleep 0.02;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glPointSize(5.0);
}

sub reshape
{
    my ($w, $h) = (shift, shift);
    state $vthalf = 2.0;
    state $hzhalf = 2.0;
    state $fa = 100.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$vthalf, $vthalf, -$hzhalf, $hzhalf, 0.0, $fa*2.0); 
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
    glutDestroyWindow( $WinID );
    exit 0;
}

sub main
{
    our $MAIN;

    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH_TEST );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("DrawArrays");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}