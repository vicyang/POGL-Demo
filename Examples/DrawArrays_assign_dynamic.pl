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
    our ($rx, $ry, $rz) = (0.0, 0.0, 0.0);

    # 每个三角形3个顶点，每个顶点3个分量
    our $tri_n = 5;
    our $vtx_n = $tri_n * 3;
    our $ele_n = $vtx_n * 3;

    our $verts  = OpenGL::Array->new($ele_n, GL_FLOAT );
    our $colors = OpenGL::Array->new($ele_n, GL_FLOAT );
}

&main();

sub display
{
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glColor4f(0.8, 0.8, 0.8, 0.5);
    #glRectf(0.0, 0.0, 500.0, 500.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    $verts->assign(0,  map { rand(1.0) } (1..$ele_n) );
    $colors->assign(0, map { rand(1.0) } (1..$ele_n) );

    # 分量，类型，间隔，指针
    glVertexPointer_c(3, GL_FLOAT, 0, $verts->ptr);
    glColorPointer_c( 3, GL_FLOAT, 0, $colors->ptr);

    #类型，偏移，顶点个数
    glDrawArrays( GL_TRIANGLES, 0, $vtx_n );
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

    glutSwapBuffers();
}

sub idle 
{
    sleep 0.05;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glPointSize(5.0);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
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
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH_TEST | GLUT_MULTISAMPLE );
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