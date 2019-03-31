use IO::Handle;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Time::HiRes 'sleep';
use feature 'state';

our $pts = 50;
our $ptx = $pts - 1;
our $bytes = $pts * 3;
our $bytex = $bytes - 1;

STDOUT->autoflush(1);
&Main();

sub display {

    my @xrr = ();
    my @crr = ();
    for my $i (0 .. $ptx) {
        $xrr[$i*3+0] = ( int(rand(5)) - 5.0 + 0.5) * 6.0;
        $xrr[$i*3+1] = ( int(rand(5)) - 5.0 + 0.5) * 6.0;
        $xrr[$i*3+2] = 0.0;

        $crr[$i*3+0] = rand(0.8)+0.2;
        $crr[$i*3+1] = rand(0.8)+0.2;
        $crr[$i*3+2] = rand(0.8)+0.2;
    }

    my $array = OpenGL::Array->new( $bytes, GL_FLOAT);
    my $crray = OpenGL::Array->new( $bytes, GL_FLOAT);
    $array->assign(0, @xrr);
    $crray->assign(0, @crr);
    glVertexPointer_c(3, GL_FLOAT, 0, $array->ptr);
    glColorPointer_c(3, GL_FLOAT, 0, $crray->ptr);

    glPushMatrix();
        glClear(GL_COLOR_BUFFER_BIT);
        glDrawArrays(GL_POINTS, 0, $ptx);
    glPopMatrix();
    glutSwapBuffers();
}

sub init {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glPointSize(30.0);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

   if (defined &OpenGL::glVertexPointerEXT_c) {
     print "Using Vertex Array...\n";
   } else {
     print "No Vertex Array extension found, using a slow method...\n";
   }

}

sub idle {
    sleep 0.1;
    glutPostRedisplay();
}

sub Reshape {
    glViewport(0.0,0.0,500.0,500.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-50.0, 50.0, -50.0, 50.0, 0.0, 200.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,100.0,0.0,0.0,0.0, 0.0,1.0,100.0);
}

sub hitkey {
    my $keychar = lc(chr(shift));
    if ($keychar eq 'q') {
        glutDestroyWindow($WinID);
        exit;
    }
}

sub Main {
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE |GLUT_MULTISAMPLE);
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

