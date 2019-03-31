use IO::Handle;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Time::HiRes 'sleep';
use feature 'state';

STDOUT->autoflush(1);
&Main();

sub display {
    our $i;
    state $R=0.0;
    state $add=0.05;
    state $ry=1.0;
    state $LiN=1.0;

    glPushMatrix();
        glRotatef($ry, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glColor3f(0.5, 0.3, 0.8);
        glBegin(GL_POLYGON);
        for ($i=0.0; $i<6.28; $i+=6.28/($LiN)) {
            glVertex3f(cos($i)*$R, sin($i)*$R, 0.0);
        }
        glEnd();
    glPopMatrix();
    glutSwapBuffers();

    if ($R > 10.0) {
        $add = -$add;
    }
    if ($R < 0.0) {
        $add = -$add;
    }
    $R+=$add if ($R < 10.0);
    $LiN+=0.05 if ($LiN < 20.0);
}

sub init {
    glClearColor(0.0, 0.0, 0.0, 1.0);
}

sub idle {
    sleep 0.01;
    glutPostRedisplay();
}

sub Reshape {
    glViewport(0.0,0.0,500.0,500.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-10.0,10.0,-10.0,10.0,0.0,200.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,100.0,0.0,0.0,0.0, 0.0,1.0,100.0);
}

sub hitkey {
    my $key = shift;
    if (lc(chr($key)) eq 'q') {
        glutDestroyWindow($WinID);
    } elsif ($key == 27) {
        glutDestroyWindow($WinID);
    }
}

sub Main {
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("title");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&Reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}


__END__
note1 比如我要建立全局变量 $t 在外面our $t是不行的
      可以再&init函数中建立