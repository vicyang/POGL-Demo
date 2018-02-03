=info
    POGL Demo - Multi Viewport
    Auth: 523066680
    Date: 2017-10
    https://github.com/vicyang/Perl-OpenGL

    2018-02 
    1. to visit the closure variable, the main function must call after the package block
    2. destroy subwindows before mainwindow
    3. all windows using one idle/reshape func, switch by glutSetWindow($winid)
=cut

use Modern::Perl;
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
    our $WIDTH  = 500;
}

{
    package subwin1;
    use Modern::Perl;
    use OpenGL qw/:all/;
    use OpenGL::Config;
    our $iter = 0.0;

    sub display
    {
        glClear( GL_COLOR_BUFFER_BIT );
        glColor4f(0.0, 0.0, 0.8, 0.5);
        glRectf(-500.0, -500.0, 500.0, 500.0);

        glColor4f(0.0, 1.0, 0.0, 1.0);
        glBegin(GL_POINTS);
        glVertex3f( $iter, 0.0, 1.0 );
        glEnd();

        glutSwapBuffers();
    }

    sub idle 
    {
        sleep 0.02;
        print "abc"; #did not happen
        glutPostRedisplay();
    }

    sub reshape
    {
        my ($w, $h) = (shift, shift);
        state $fa = 100.0;
        glViewport( 0.0, 0.0, $w, $h );
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-100.0, 100.0, -100.0,100.0, 0.0, $fa*2.0); 
        #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
    }
}

{
    package subwin2;
    use OpenGL qw/:all/;
    use OpenGL::Config;
    our $iter = 0.0;

    sub display
    {
        glClear( GL_COLOR_BUFFER_BIT );
        glColor4f(0.8, 0.8, 0.0, 0.5);
        glRectf(-500.0, -500.0, 500.0, 500.0);
        glColor4f(0.0, 0.0, 1.0, 1.0);
        glPointSize(4.0);
        glBegin(GL_POINTS);
        glVertex3f( $iter, 0.0, 1.0 );
        glEnd();
        glutSwapBuffers();
    }

    sub reshape
    {
        my ($w, $h) = (shift, shift);
        state $fa = 100.0;
        glViewport( 50.0, 50.0, $w, $h );
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-100.0, 100.0, -100.0,100.0, 0.0, $fa*2.0); 
        #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
    }
}

{
    package mainwin;
    use OpenGL qw/:all/;
    use OpenGL::Config;

    sub display
    {
        glClear( GL_COLOR_BUFFER_BIT );
        glutSwapBuffers();
    }

    sub idle 
    {
        sleep 0.01;
        $subwin1::iter++;
        $subwin2::iter--;
        glutSetWindow( $main::SUB1 );
        glutPostRedisplay();
        glutSetWindow( $main::SUB2 );
        glutPostRedisplay();
    }

    sub reshape
    {
        my ($w, $h) = (shift, shift);
        state $fa = 100.0;
        glViewport(0.0, 0.0, $w, $h);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-100.0, 100.0, -100.0,100.0, 0.0, $fa*2.0); 
        #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
    }
}

&main();

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glPointSize(2.0);
}

sub hitkey 
{
    our ( $MAIN, $SUB1, $SUB2 );
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
}

sub quit
{
    our ($MAIN, $SUB1, $SUB2);
    # destroy sub windows first
    glutDestroyWindow( $SUB1 );
    glutDestroyWindow( $SUB2 );    
    glutDestroyWindow( $MAIN );
    exit 0;
}

sub main
{
    our ($MAIN, $WIDTH, $HEIGHT);

    glutInit();
    glutInitDisplayMode( GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $MAIN = glutCreateWindow("SubWindow");
    
    init();
    glutDisplayFunc( \&mainwin::display );
    glutReshapeFunc( \&mainwin::reshape );
    glutIdleFunc( \&mainwin::idle );
    glutKeyboardFunc( \&hitkey );

    our $SUB1 = glutCreateSubWindow( $MAIN, 0, 0, 240, 240 );
    glutDisplayFunc( \&subwin1::display );
    glutReshapeFunc( \&subwin1::reshape );
    #glutIdleFunc( \&subwin1::idle );
    glutKeyboardFunc( \&hitkey );

    our $SUB2 = glutCreateSubWindow( $MAIN, 260, 260, 240, 240 );
    glutDisplayFunc( \&subwin2::display );
    glutReshapeFunc( \&subwin2::reshape );
    #glutIdleFunc( \&subwin2::idle );
    glutKeyboardFunc( \&hitkey );

    glutSetWindow( $MAIN );
    glutPostRedisplay();
    glutSetWindow( $SUB1 );
    glutPostRedisplay();
    glutSetWindow( $SUB2 );
    glutPostRedisplay();

    glutMainLoop();
}

