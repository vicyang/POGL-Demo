use feature 'state';
use IO::Handle;
use OpenGL qw/ :all /;
use OpenGL::Config;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    our ($rx, $ry, $rz) = (0.0, 0.0, 0.0);

    our $count = 100;
    our @verts  = map { rand(1.0), rand(1.0), rand(1.0) } ( 1.. $count );
    our @colors = map { rand(1.0), rand(1.0), rand(1.0) } ( 1.. $count );

    for ( my $i = 0; $i <= $#verts; $i+=3 )
    {
        printf "%.3f, %.3f, %.3f\n", $verts[$i], $verts[$i+1], $verts[$i+2] ;
    }
}

&main();

sub display
{
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    my $verts  = OpenGL::Array->new_list( GL_FLOAT, @verts );
    my $colors = OpenGL::Array->new_list( GL_FLOAT, @colors );

    # 分量，类型，间隔，指针
    glVertexPointer_c(3, GL_FLOAT, 0, $verts->ptr);
    glColorPointer_c( 3, GL_FLOAT, 0, $colors->ptr);

    #类型，偏移，顶点*分量的个数（注意不是顶点的个数，通常每个顶点三个分量）
    glDrawArrays( GL_TRIANGLES, 0, 30 );
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

    glPopMatrix();
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
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glPointSize(5.0);
}

sub reshape
{
    my ($w, $h) = (shift, shift);
    state $vthalf = 1.0;
    state $hzhalf = 1.0;
    state $fa = 100.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho( 0.0, $hzhalf, 0.0, $vthalf, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey
{
    our $WinID;
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }

    if ( $k eq 'a') 
    {
        @verts  = map { rand(1.0) } ( 1.. $count *3 );
        @colors = map { rand(1.0) } ( 1.. $count *3 );
    }

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