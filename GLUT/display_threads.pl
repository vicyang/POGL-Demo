=info
    Auth: 523066680/vicyang
    Date: 2018-11
=cut

use feature 'state';
use Time::HiRes qw/sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use threads;
use threads::shared;
STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    our $iter :shared;
}

my $C = [0];
my $th = threads->create(\&func, $C->[0],  $C->[0] );
$th->detach();
&main();

sub func
{
    my ( $id ) = @_;

    while (1)
    {
        $iter += 1.0;
        sleep rand(0.2);
        print "in thread $id, sleep $rnd\n";
    }
}

sub display
{
    our $iter;
    printf "$iter\n";

    glColor3f(1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POINTS);
        glVertex3f( $iter*2.0, 0.0, 0.0 );
    glEnd();
    glutSwapBuffers();
}

sub idle 
{
    sleep 0.05;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glPointSize(5.0);
}

sub reshape
{
    my ($w, $h) = (shift, shift);
    state $vthalf = $w/2.0;
    state $hzhalf = $h/2.0;
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
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("Display");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}