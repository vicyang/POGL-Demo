=info
    Auth: 523066680
    Date: 2018-11
=cut

use warnings 'all';
use utf8;
use Encode;
use feature 'state';
use Time::HiRes qw/sleep/;
use Data::Dumper;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Font::FreeType;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
}

INIT
{
    our %TEXT;
    our ($font, $size) = ("C:/windows/fonts/STXINGKA.TTF", 20);
    our $dpi = 100;
    our $face = Font::FreeType->new->face($font);
    $face->set_char_size($size, $size, $dpi, $dpi);

    print "Loading contours ... ";
    my $code;
    my $char;
    foreach $code (0x00..0x7F)
    {
        $char = chr( $code );
        $TEXT{ $char } = get_contour( $char ); 
    }

    foreach $char (split //, "天之道，损有余而补不足。")
    {
        $TEXT{ $char } = get_contour( $char ); 
    }
    print "Done\n";

    #创建颜色插值表
    our $table_size = 360;
    our @color_idx;
    for (0 .. $table_size) {
        push @color_idx, { 'R' => 0.0, 'G' => 0.0, 'B' => 0.0 };
    }

    fill_color(0, 6,  0.0, 0.8, 1.0);
    fill_color(5, 10, 0.3, 1.0, 0.8);
    fill_color(12, 20, 1.0, 0.8, 0.5);

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
}

=struct
    $hash = {
        'day1' => { 'time1' => [@data], 'time2' => [@data] }, 
        'day2' => { ... }, ...
     }
=cut

&main();

sub display 
{
    glClear( GL_COLOR_BUFFER_BIT );
    glColor3f(0.6, 0.8, 1.0);

    # 应为 draw_string 函数使用 Translatef 偏移字符位置，所以需要 PushMatrix
    glPushMatrix();
    glTranslatef(0.0, -30.0, 0.0);
    draw_string("Github: vicyang");
    glPopMatrix();

    glPushMatrix();
    my $iter = 0;
    for my $c ( split("", "天之道，损有余而补不足。") )
    {
        glColor3f( @{$color_idx[ $iter ]}{'R','G','B'} );
        draw_character( $c );
        glTranslatef($TEXT{$c}->{right}, 0.0, 0.0);
        $iter++;
    }   
    glPopMatrix();

    glutSwapBuffers();
}

sub idle 
{
    sleep 0.1;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glPointSize(1.0);
    glLineWidth(1.0);
    glEnable(GL_BLEND);
    #glEnable(GL_DEPTH_TEST);
    glEnable(GL_POINT_SMOOTH);
    glEnable(GL_LINE_SMOOTH);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    $tobj = gluNewTess();
    gluTessCallback($tobj, GLU_TESS_BEGIN,     'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_END,       'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_VERTEX,    'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_COMBINE,   'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_ERROR,     'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_EDGE_FLAG, 'DEFAULT');
}

sub reshape 
{
    my ($w, $h) = (shift, shift);
    #Same with screen size
    my $hz_half = $w/2.0;
    my $vt_half = $h/2.0;
    my $fa = 10.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$hz_half, $hz_half, -$vt_half, $vt_half, 0.0, $fa*2.0); 
    #gluPerspective( 45.0, 1.0, 1.0, $fa*2.0 );
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
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_MULTISAMPLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    our $WinID = glutCreateWindow("Font::Freetype");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}

DRAW_STRING:
{
    sub draw_character
    {
        our @TEXT;
        my $char = shift;
        my $cts;
        gluTessBeginPolygon($tobj);
        for $cts ( @{$TEXT{$char}->{outline}} )
        {
            gluTessBeginContour($tobj);
            grep { gluTessVertex_p($tobj, @$_, 0.0 ) } @$cts;
            gluTessEndContour($tobj);
        }
        gluTessEndPolygon($tobj);
    }

    sub draw_string
    {
        my $s = shift;
        for my $c ( split //, $s )
        {
            draw_character($c);
            if ( defined $TEXT{$c}->{right} )
                { glTranslatef( $TEXT{$c}->{right}, 0.0, 0.0 ); }
            else 
                { printf "Wrong character %x\n", ord($c);       }
        }
    }

    sub pointOnLine
    {
        my ($x1, $y1, $x2, $y2, $t) = @_;
        return (
            ($x2-$x1)*$t + $x1, 
            ($y2-$y1)*$t + $y1 
        );
    }

    sub pointOnQuadBezier
    {
        my ($x1, $y1, $x2, $y2, $x3, $y3, $t) = @_;
        return 
            pointOnLine(
                   pointOnLine( $x1, $y1, $x2, $y2, $t ),
                   pointOnLine( $x2, $y2, $x3, $y3, $t ),
                   $t
            );
    }

    sub get_contour
    {
        our $glyph;
        my $char = shift;
        #previous x, y
        my ($px, $py, $parts, $step);
        my @contour = ();
        my $ncts    = -1;
        
        $parts = 5;
        $glyph = $face->glyph_from_char($char) || return undef;

        $glyph->outline_decompose(
            move_to  => 
                sub 
                {
                    ($px, $py) = @_;
                    $ncts++;
                    push @{$contour[$ncts]}, [$px, $py];
                },
            line_to  => 
                sub
                {
                    ($px, $py) = @_;
                    push @{$contour[$ncts]}, [$px, $py];
                },
            conic_to => 
                sub
                {
                    for ($step = 0.0; $step <= $parts; $step+=1.0)
                    {
                        push @{$contour[$ncts]}, 
                            [ pointOnQuadBezier( $px, $py, @_[2,3,0,1], $step/$parts ) ];
                    }
                    ($px, $py) = @_;
                },
            cubic_to => sub { warn "cubic\n"; }
        );

        return { 
            outline => [@contour],
            right   => $glyph->horizontal_advance(),
        };
    }

}