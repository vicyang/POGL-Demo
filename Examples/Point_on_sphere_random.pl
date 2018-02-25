=info
    使用随机 半径 和随机角度的方法，产生的点，越往中间越密集

    参考文章：
    http://blog.csdn.net/shakingwaves/article/details/17969025
    https://thecodeway.com/blog/?p=1138
=cut

use Modern::Perl;
use IO::Handle;
use List::Util qw/max min/;
use Time::HiRes qw/sleep time/;
use OpenGL qw/ :all /;
use OpenGL::Config;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 600;
    our $WIDTH  = 800;
    our ($show_w, $show_h) = (80, 60);
    our ($half_w, $half_h) = ($show_w/2.0, $show_h/2.0);

    # 全局旋转角度
    our ( $rx, $ry, $rz ) = ( 0.0, 0.0, 0.0 );


    # 初速度
   	our $g = 9.8;
   	our $ta = time();

    #创建随机颜色表
    our $total = 500;
    our @colormap;
    #srand(0.5);
    grep { push @colormap, [ 0.3+rand(0.7), 0.3+rand(0.7), 0.3+rand(0.7) ] } ( 0 .. $total );

    our @dots;
    my ($inx, $iny, $inz);
    my ($len, $ang);

    for ( 0 .. $total )
    {
        #($len, $ang) = ( rand(20.0), rand(6.28) );
        ($len, $ang) = ( sqrt(rand(1.0))*20.0, rand(6.28) );
        $inx = $len * sin( $ang );
        $iny = $len * cos( $ang );

        push @dots, { xyz => [ $inx, $iny, 0.0 ], rgb => $colormap[ $_ ] };
    }

}

&main();

sub display
{
    our ( @dots );
    our ( $rx, $ry, $rz );
	my $t;
	state $iter = 0.0;
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    my ($x, $y, $z);

    glPushMatrix();
    glRotatef( $rx, 1.0, 0.0, 0.0 );
    glRotatef( $ry, 0.0, 1.0, 0.0 );
    glRotatef( $rz, 0.0, 0.0, 1.0 );

    glBegin(GL_POINTS);
    for my $dot ( @dots )
    {
        ($x, $y, $z ) = @{ $dot->{xyz} };
        glColor3f( @{ $dot->{rgb} } );
        glVertex3f( $x, $y, $z);
        #glVertex3f( $dot->{x}, $dot->{y}, 0.0);
    }
    glEnd();

    glutWireCube( 50.0 );

    glPopMatrix();

    glutSwapBuffers();
}

sub idle 
{
    our (@dots, @colormap, $total);
    state $iter = 0;
    sleep 0.02;
    glutPostRedisplay();

    $iter++;
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glPointSize(6.0);
}

sub reshape
{
    our ($show_w, $show_h, $half_w, $half_h);
    state $fa = 200.0;
    my ($w, $h) = (shift, shift);
    my ($max, $min) = (max($w, $h), min($w, $h) );

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    #glOrtho( -$half_w, $half_w, -$half_h, $half_h, 0.0, $fa*2.0); 
    glFrustum( -$half_w, $half_w, -$half_h, $half_h, 150.0, $fa*2.0 ); 
    #gluPerspective( 45.0, 1.0, 10.0, $fa*2.0 );
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0,$fa);
}

sub hitkey
{
    our ($WinID, $rx, $ry, $rz );
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
    elsif ( $k eq 'w' ) { $rx += 1.0 }
    elsif ( $k eq 's' ) { $rx -= 1.0 }
    elsif ( $k eq 'a' ) { $ry -= 1.0 }
    elsif ( $k eq 'd' ) { $ry += 1.0 }

}

sub quit
{
    our ($WinID);
    glutDestroyWindow( $WinID );
    exit 0;
}

sub main
{
    our ($WIDTH, $HEIGHT, $WinID);

    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH | GLUT_MULTISAMPLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("Point on Circle");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}