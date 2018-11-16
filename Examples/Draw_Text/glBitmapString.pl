=info
    BitmapCharacter 字体常量
    http://freeglut.sourceforge.net/docs/api.php
    14. Font Rendering Functions
    GLUT_BITMAP_8_BY_13 - A variable-width font with every character fitting in a rectangle of 13 pixels high by at most 8 pixels wide.
    GLUT_BITMAP_9_BY_15 - A variable-width font with every character fitting in a rectangle of 15 pixels high by at most 9 pixels wide.
    GLUT_BITMAP_TIMES_ROMAN_10 - A 10-point variable-width Times Roman font.
    GLUT_BITMAP_TIMES_ROMAN_24 - A 24-point variable-width Times Roman font.
    GLUT_BITMAP_HELVETICA_10 - A 10-point variable-width Helvetica font.
    GLUT_BITMAP_HELVETICA_12 - A 12-point variable-width Helvetica font.
    GLUT_BITMAP_HELVETICA_18 - A 18-point variable-width Helvetica font.
=cut

use v5.16;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Time::HiRes 'sleep';

STDOUT->autoflush(1);

our $SIZE_X = 800;
our $SIZE_Y = 800;

our $WinID;
our $PI  = 3.1415926536;
our $PI2 = $PI * 2;
our $MAX_LEVEL = 10;

&Main();

sub display 
{
    glClear(GL_COLOR_BUFFER_BIT);

    my @fonts = (
            GLUT_BITMAP_8_BY_13, 
            GLUT_BITMAP_9_BY_15, 
            GLUT_BITMAP_TIMES_ROMAN_10, 
            GLUT_BITMAP_TIMES_ROMAN_24, 
            GLUT_BITMAP_HELVETICA_10, 
            GLUT_BITMAP_HELVETICA_12, 
            GLUT_BITMAP_HELVETICA_18, 
        );

    for my $id ( 0 .. $#fonts )
    {
        glRasterPos3f( 0.0, -$id * 6.0, 0.0);
        glutBitmapString( $fonts[$id], "abc 123");

        glRasterPos3f( -20.0, -$id * 6.0, 0.0);
        glutBitmapCharacter( $fonts[$id], ord("a"));
    }

    glFlush();
}

sub init 
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glLineWidth(2.0);
    glPointSize(2.0);
}

sub idle 
{
    sleep 0.1;
    glutPostRedisplay();
}

sub Reshape 
{
    my $half = 100.0;
    glViewport(0.0,0.0, $SIZE_X, $SIZE_Y);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$half, $half, -$half, $half,-20.0,200.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,100.0,0.0,0.0,0.0, 0.0,1.0,100.0);
}

sub hitkey 
{
    my $key = shift;
    if (lc(chr($key)) eq 'q') 
    {
        glutDestroyWindow($WinID);
    }
    elsif ($key == 27) 
    {
        glutDestroyWindow($WinID);
    }
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_SINGLE |GLUT_MULTISAMPLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("title");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&Reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}

