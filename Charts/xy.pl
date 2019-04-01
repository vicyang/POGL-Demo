use Modern::Perl;
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

sub printstr 
{
    for my $i ( split("", $_[0]) ) 
    {
        #glutBitmapCharacter(GLUT_BITMAP_9_BY_15, ord($i));
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, ord($i));        
    }
}

sub display 
{
    our $i;

    glClear(GL_COLOR_BUFFER_BIT);


    glPushMatrix();
    glTranslatef(-1.0, -1.0, 0.0);
    glScalef(3.0, 3.0, 3.0);

    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_LINES);
        glVertex3f(-200.0, 0.0, 0.0);
        glVertex3f(200.0, 0.0, 0.0);
        glVertex3f(0.0, -200.0, 0.0);
        glVertex3f(0.0, 200.0, 0.0);
    glEnd();

    glColor3f(1.0, 0.0, 0.0);
    glBegin(GL_POINTS);
    my $v;
    my $t;
    for (my $t = 0.0; $t<=1.0; $t += 0.05)  #t maxvalue is 1.0
    {
        $v = 3*$t - 6 * $t * $t + 3*$t*$t*$t;
        glVertex3f($t, $v, 0.0);
    }
    glEnd();

    for (my $t = 0.0; $t<=1.0; $t += 0.05)  #t maxvalue is 1.0
    {
        $v = 3*$t - 6 * $t * $t + 3*$t*$t*$t;
        glRasterPos3f($t, $v, 0.0);
        printstr( sprintf("%.2f", $t) );
        glRasterPos3f($t, $v-0.02, 0.0);
        printstr( sprintf("%.2f", $v) );
    }

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
