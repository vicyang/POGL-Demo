use v5.16;
use utf8;
use IO::Handle;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Time::HiRes 'sleep';

STDOUT->autoflush(1);

our $SIZE_X = 500;
our $SIZE_Y = 500;

our $WinID;
our $PI  = 3.1415926536;
our $PI2 = $PI * 2;
our $MAX_LEVEL = 10;

&Main();

sub printstr 
{
    for my $i ( split("", $_[0]) ) 
    {
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, ord($i));
        #glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, ord($i));        
    }
}

sub display 
{
    glClear(GL_COLOR_BUFFER_BIT);
    glPushMatrix();
    glRasterPos3f(0.0, 0.5, 0.0);
    printstr( sprintf("%.2f", 1.2) );
    glutBitmapString(GLUT_BITMAP_9_BY_15, "String" );
    glPopMatrix();
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
    my $half = 2.0;
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

