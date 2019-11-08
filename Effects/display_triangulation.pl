=info
    Auth: 523066680
=cut

use Modern::Perl;
use utf8;
use Encode;
use autodie;
use Storable;
use feature 'state';
use Time::HiRes qw/sleep time/;
use Time::Local;
use File::Slurp;
use Data::Dumper;
use List::Util qw/sum min max/;

use OpenGL qw/ :all /;
use OpenGL::Config;

BEGIN
{
    use FindBin;
    use lib $FindBin::Bin ."/lib";
    use Font::FreeType;
    use Math::Geometry::Delaunay;
    use IO::Handle;
    STDOUT->autoflush(1);

    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    our ($rx, $ry, $rz, $zoom) = (0.0, 0.0, 0.0, 1.0);
    our ($mx, $my, $mz) = (0.0, 0.0, 0.0);
    our @points = map { [ map { rand(300.0) } (1..3) ] } (1..20) ;
}

INIT
{
    our $CLOCK;
    print "Loading contours ... ";
    my $code;
    my $char;

    #创建颜色插值表
    our $table_size = 320;
    our @color_idx;
    for (0 .. $table_size) {
        push @color_idx, { 'R' => 0.0, 'G' => 0.0, 'B' => 0.0 };
    }

    fill_color( 20, 60, 1.0, 0.3, 0.3);
    fill_color(100,100, 1.0, 0.6, 0.0);
    fill_color(200,100, 0.2, 0.8, 0.2);
    fill_color(300,300, 0.2, 0.6, 1.0);

    sub fill_color 
    {
        my %insert;
        @{insert}{'offset', 'length', 'R', 'G', 'B'} = @_;
        my $site;
        my $ref;
        my $tc;

        for my $i (  -$insert{length} .. $insert{length} )
        {
            $site = $i + $insert{offset};
            next if ($site < 0 or $site > $table_size);
            $ref = $color_idx[$site];
            for my $c ('R', 'G', 'B') 
            {
                $tc = $insert{$c} - abs( $insert{$c} / $insert{length} * $i),  #等量划分 * step
                $ref->{$c} = $ref->{$c} > $tc ? $ref->{$c} : $tc  ;
            }
        }
    }

    sub triangulation
    {
        my $points = shift;
        my $tri = new Math::Geometry::Delaunay();
        $tri->addPoints( $points );
        $tri->doEdges(1);
        $tri->doVoronoi(1);
        $tri->triangulate();
        return $tri->elements();
    }
}

&main();

sub display 
{
    our ($zoom, $rx, $ry, $rz, $mx, $my, $mz, @color_idx, @points);
    state $i = 0;

    my $day;
    my ($hour, $time);
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    glColor4f(0.8, 0.8, 0.8, 0.5);

    glPushMatrix();
    glScalef( $zoom, $zoom, $zoom );
    glRotatef($rx, 1.0, 0.0, 0.0);
    glRotatef($ry, 0.0, 1.0, 0.0);
    glRotatef($rz, 0.0, 0.0, 1.0);
    glTranslatef($mx, $my, $mz);

    my $bright = 1.0;
    my $color;
    
    $points[0] = [ rand(200), rand(200), rand(200) ];

    glEnable(GL_LIGHTING);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    my $tri;
    my (@tpa, @tpb, @norm);
    $tri = triangulation( \@points );
    glBegin(GL_TRIANGLES);
    for my $a ( @$tri ) 
    {
        for my $i ( 0 .. 2 )
        {
            $tpa[$i] = $a->[1][$i] - $a->[0][$i] ;
            $tpb[$i] = $a->[2][$i] - $a->[0][$i] ;
        }
        normcrossprod( \@tpa, \@tpb, \@norm );
        glNormal3f( @norm );
        for my $b ( @$a ) 
        {
            $bright = abs($b->[1])/100.0;
            $color = $color_idx[int($b->[2])];
            glColor4f( $color->{R} * $bright, $color->{G} * $bright, $color->{B} * $bright, 0.5 );
            glVertex3f( @$b[0,2,1] );
        }
    }
    glEnd();
    glDisable(GL_LIGHTING);

    glPopMatrix();
    glutSwapBuffers();
}

sub idle 
{
    state $t1;
    state $delta;
    state $delay = 0.065;
    state $left;

    $t1 = time();

    #glutPostRedisplay();
    display();

    $delta = time()-$t1;
    $left = sprintf "%.3f", $delay - $delta;
    sleep $left if $left > 0.0;

    #printf "%.4f %.4f %.4f\n", time()-$t1, $delta, $left;
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    #glClearColor(0.1, 0.2, 0.3, 1.0);
    glPointSize(1.0);
    glLineWidth(1.0);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_POINT_SMOOTH);
    glEnable(GL_LINE_SMOOTH);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    glEnable(GL_LIGHTING);

    my $ambient  = OpenGL::Array->new( 4, GL_FLOAT);
    my $specular = OpenGL::Array->new( 4, GL_FLOAT);
    my $diffuse  = OpenGL::Array->new( 4, GL_FLOAT);
    my $shininess = OpenGL::Array->new( 1, GL_FLOAT);

    my $light_position = OpenGL::Array->new( 4, GL_FLOAT);
    my $light_specular = OpenGL::Array->new( 4, GL_FLOAT);
    my $light_diffuse  = OpenGL::Array->new( 4, GL_FLOAT);

    $ambient->assign(0,  ( 0.5, 0.5, 0.5, 1.0 ) );
    $specular->assign(0, ( 0.5, 0.5, 0.5, 1.0 ) );
    $diffuse->assign(0,  ( 1.0, 1.0, 1.0, 1.0 ) );
    $shininess->assign(0,  100.0 );

    $light_diffuse->assign(0, ( 1.0, 1.0, 1.0, 1.0 ) );
    $light_specular->assign(0, ( 0.2, 0.2, 0.2, 1.0 ) );
    $light_position->assign(0, ( 0.0, 1.0, 1.0, 1.0 ) );

    glMaterialfv_c(GL_FRONT_AND_BACK, GL_AMBIENT, $ambient->ptr );
    glMaterialfv_c(GL_FRONT_AND_BACK, GL_SPECULAR, $specular->ptr );
    glMaterialfv_c(GL_FRONT_AND_BACK, GL_DIFFUSE, $diffuse->ptr );
    glMaterialfv_c(GL_FRONT_AND_BACK, GL_SHININESS, $shininess->ptr );

    glLightfv_c(GL_LIGHT0, GL_POSITION, $light_position->ptr);
    glLightfv_c(GL_LIGHT0, GL_DIFFUSE, $light_diffuse->ptr);
    glLightfv_c(GL_LIGHT0, GL_SPECULAR, $light_specular->ptr);

    glEnable(GL_LIGHT0);

    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);

}

sub reshape 
{
    our ($WIDTH, $HEIGHT);
    my ($w, $h) = (shift, shift);
    #Same with screen size
    state $hz_half = $WIDTH/2.0;
    state $vt_half = $HEIGHT/2.0;
    state $fa = 1000.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    #glOrtho(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 0.0, $fa*2.0); 
    #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
    gluPerspective( 45.0, 1.0, 1.0, $fa*2.0 );
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    #gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
    gluLookAt(200.0,200.0,$fa, 200.0,200.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    our ($WinID, $zoom, $rx, $ry, $rz, $mx, $my, $mz);
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
    if ( $k eq 'r') { ($rx, $ry, $rz) = (0.0, 0.0,0.0)  }

    if ( $k eq '4') { $mx-=10.0 }
    if ( $k eq '6') { $mx+=10.0 }
    if ( $k eq '8') { $my+=10.0 }
    if ( $k eq '2') { $my-=10.0 }
    if ( $k eq '5') { $mz+=10.0 }
    if ( $k eq '0') { $mz-=10.0 }

    if ( $k eq 'w') { $rx+=5.0 }
    if ( $k eq 's') { $rx-=5.0 }
    if ( $k eq 'a') { $ry-=5.0 }
    if ( $k eq 'd') { $ry+=5.0 }
    if ( $k eq 'j') { $rz+=5.0 }
    if ( $k eq 'k') { $rz-=5.0 }
    if ( $k eq '[') { $zoom -= $zoom*0.1 }
    if ( $k eq ']') { $zoom += $zoom*0.1 }
}

sub quit
{
    our $WinID;
    glutDestroyWindow( $WinID );
    exit 0;
}

sub main
{
    our ($WIDTH, $HEIGHT);
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE |GLUT_DEPTH | GLUT_MULTISAMPLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    our $WinID = glutCreateWindow("Display");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}

sub time_to_date
{
    my ($sec, $min, $hour, $day, $mon, $year) = localtime( shift );
    $mon += 1;
    $year += 1900;
    return sprintf "%d-%02d-%02d", $year,$mon,$day;
}

LIGHT:
{
    sub normalize
    {
        my $v = shift;
        my $d = sqrt($v->[0]*$v->[0] + $v->[1]*$v->[1] + $v->[2]*$v->[2]);
        if ($d == 0.0)
        {
            printf("length zero!\n");
            return;
        }
        $v->[0] /= $d;
        $v->[1] /= $d;
        $v->[2] /= $d;
    }

    sub normcrossprod
    {
        my ( $v1, $v2, $out ) = @_;

        $out->[0] = $v1->[1] * $v2->[2] - $v1->[2] * $v2->[1];
        $out->[1] = $v1->[2] * $v2->[0] - $v1->[0] * $v2->[2];
        $out->[2] = $v1->[0] * $v2->[1] - $v1->[1] * $v2->[0];

        normalize( $out );
    }
}