=info
    DLX 解数独方案，Perl 实现
    523066680 2017-09

    https://zhuanlan.zhihu.com/PerlExample
    0.41_multi 基本完善
    0.5 格式调整
    0.51 去掉 print_nodes函数
=cut

use strict;
#use warnings; # Can't locate package GLUquadricObjPtr for @OpenGL::Quad::ISA 
use feature 'state';
use Clone 'clone';
use Time::HiRes qw/sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use RandMatrix;
use DancingLinks;
use Data::Dumper;
$Data::Dumper::Maxdepth = 2;
use threads;
use threads::shared;
STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 600;
    our $WIDTH  = 1000;
    our @color_table = (
            [0.0, 0.0, 1.0], [1.0, 1.0, 0.0], [1.0, 0.0, 1.0],
            [0.0, 1.0, 1.0], [0.5, 1.0, 0.5], [1.0, 0.5, 0.5],
            [0.5, 0.5, 1.0], [0.3, 0.5, 0.8], [0.5, 0.3, 0.8],
            [0.8, 0.5, 0.3],
        );
    #our $C = [ map { {} } ( 0.. $mat_cols ) ];
}

our $mat;
our $mat_rows = 10;
our $mat_cols = 20;
make_mat( \$mat, $mat_rows, $mat_cols );
DancingLinks::init( $mat, $mat_rows, $mat_cols  );

our @answer =  map { [] } (1..20);
share(@answer);
our $C = clone( $DancingLinks::C );
our $SHARE :shared;
#grep { printf "%s\n", join( "", @$_ ) } @$SHARE;

#exit;

DancingLinks::print_links( $C->[0] );
my $th = threads->create( \&dance, $C->[0], \@answer, 0 );
$th->detach();
#printf "%s\n", join(",", map { $_->{row} } @answer);

main();

DANCING:
{
    sub clone_DLX
    {
        our $SHARE;
        my ( $head, $ref )= @_;

        my $vt;
        my $hz;
        my $c = $head->{right};
        $SHARE = shared_clone( [ map { [map { 0 } (0..$mat_cols)] } (0..$mat_rows) ] );
        for ( ; $c != $head; $c = $c->{right} )
        {
            $ref->[0][ $c->{col} ] = shared_clone( $c );
            $vt = $c->{down};
            for ( ; $vt != $c; $vt = $vt->{down} )
            {
                $SHARE->[$vt->{row}][$vt->{col}] = shared_clone( $vt );
            }
        }
    }

    sub dance
    {
        our $SHARE;
        my ($head, $answer, $lv) = @_;

        clone_DLX( $head, $SHARE );
        sleep 0.5;
        return 1 if ( $head->{right} == $head );

        my $c = $head->{right};
        my $min = $c;

        #get minimal column node
        while ( $c != $head )
        {
            if ( $c->{count} < $min->{count} ) { $min = $c; }
            $c = $c->{right};
        }

        $c = $min;
        return 0 if ( $c->{count} <= 0 );

        my $r = $c->{down};
        my $ele;

        my @count_array;
        my $res = 0;

        remove_col( $c );

        while ( $r != $c )
        {
            
            $ele = $r->{right};

            while ( $ele != $r )
            {
                remove_col( $ele->{top} );
                $ele = $ele->{right};
            }

            $res = dance($head, $answer, $lv+1);
            if ( $res == 1)
            {
                $answer->[$lv] = shared_clone($r);
                return 1;
            }

            $ele = $r->{left};
            while ( $ele != $r )
            {
                resume_col( $ele->{top} );
                $ele = $ele->{left};
            }
         
            $r = $r->{down};
        }

        resume_col( $c );
        return $res;
    }

    sub remove_col
    {
        my ( $sel ) = @_;

        $sel->{left}{right} = $sel->{right};
        $sel->{right}{left} = $sel->{left};

        my $vt = $sel->{down};
        my $hz;

        for ( ; $vt != $sel; $vt = $vt->{down} )
        {
            $hz = $vt->{right};
            for (  ; $hz != $vt; $hz = $hz->{right})
            {
                $hz->{up}{down} = $hz->{down};
                $hz->{down}{up} = $hz->{up};
                $hz->{top}{count} --;
            }
            $hz->{top}{count} --;
        }
    }

    sub resume_col
    {
        my ( $sel ) = @_;

        $sel->{left}{right} = $sel;
        $sel->{right}{left} = $sel;

        my $vt = $sel->{down};
        my $hz;

        for ( ; $vt != $sel; $vt = $vt->{down})
        {
            $hz = $vt->{right};
            for (  ; $hz != $vt; $hz = $hz->{right})
            {
                $hz->{up}{down} = $hz;
                $hz->{down}{up} = $hz;
                $hz->{top}{count} ++;
            }
            $hz->{top}{count} ++;
        }
    }
}

sub make_mat
{
    my ($ref, $rows, $cols) = @_;
    $RandMatrix::n = 8;     #实际有效的行数
    $RandMatrix::m = $cols;
    RandMatrix::create_mat( $ref );
    RandMatrix::fill_rand_row( $$ref, $rows - $RandMatrix::n );
    RandMatrix::dump_mat( $$ref );
}

sub display
{
    our ($C, @SAVE, $DID, @color_table, $WinID, $SHARE);
    glColor3f(1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    grep { printf "%s\n", join( "", @$_ ) } @$SHARE;
    # printf "\n";
=info
    my $vt;
    my $hz;
    my $head = $SHARE->[0];
    my $c = $head->{right};
    return if ($head->{right} == $head);

    #DancingLinks::print_links( $head );

    glBegin(GL_POINTS);
    for ( ; $c != $head; $c = $c->{right} )
    {
        glVertex3f( $c->{col}*4.0, -$c->{row}*4.0, 0.0 );
        $vt = $c->{down};
        for ( ; $vt != $c; $vt = $vt->{down} )
        {
            #printf "%d %d %d\n", $vt->{row}, $vt->{col}, $vt->{val};
            #glColor3f( @{$color_table[ $vt->{val} ]} );
            glVertex3f( $vt->{col}*4.0, -$vt->{row}*4.0, 0.0 );
        }
    }
    glEnd();
=cut
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
    glPointSize(2.0);
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
    glOrtho(-100, $w-100, -$hzhalf, $hzhalf, 0.0, $fa*2.0); 
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
    our $WinID;
    glutDestroyWindow( $WinID );
    exit 0;
}

sub main
{
    our ($MAIN, $WIDTH, $HEIGHT, $WinID);

    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("Show");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
