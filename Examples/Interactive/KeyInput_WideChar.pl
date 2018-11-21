=info
    Auth: 523066680
    Date: 2018-11
=cut

use utf8;
use Encode;
use feature 'state';
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Data::Dumper;
use Imager;
STDOUT->autoflush(1);

our $WIDTH = 620;
our $HEIGHT = 520;
our $WinID;
our $pause = 0;
our $input = 'a';

INIT
{
    our $SIZE = 30;
    our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/msyh.TTF'), #STXINGKA.TTF
                              size  => $SIZE );
    our $bbox = $font->bounding_box(string=>"_");

    # 创建标签字符模板
    our @TEXT = ('a'..'z', 'A'..'Z', '0'..'9');
    our %TEXT_DATA;

    for my $s ( @TEXT )
    {
        $TEXT_DATA{$s} = {};
        get_text_map( $s , $TEXT_DATA{$s} );
    }
}

Main();

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->advance_width,
                          ysize=>$bbox->font_height, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
            filled => 1, color => '#336699');

    $img->align_string(
               font  => $font,
               text  => $char,
               x     => $w/2.0,
               y     => $h + $bbox->global_descent,
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
               halign => 'center',
            );

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $h - 1 )
    {
        @colors = $img->getscanline( y => $y );
        grep { push @rasters, $_->rgba  } @colors;
    }

    $ref->{h} = $h, $ref->{w} = $w;
    $ref->{array} = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $ref->{array}->assign(0, @rasters);
}

sub display
{
    our ($WIDTH, $HEIGHT, $input);
    state $iter = -1;
    state $xbase = 10.0;
    state $ybase = 200.0;
    glClear(GL_COLOR_BUFFER_BIT);

    my $ref;
    if (not defined $input)
    {
        glutSwapBuffers();
        return;
    }
    
    if ( exists $TEXT_DATA{ $input } )
    {
        $ref = $TEXT_DATA{ $input };
        glRasterPos3f( $xbase , $ybase, 0.0 );
        glDrawPixels_c( $ref->{w}, $ref->{h}, GL_RGBA, GL_UNSIGNED_BYTE, $ref->{array}->ptr() );
        # $input = undef;
    }
    else
    {
        $TEXT_DATA{$input} = {};
        get_text_map( decode('gbk', $input), $TEXT_DATA{$input} );
        $ref = $TEXT_DATA{$input};
        glRasterPos3f( $xbase, $ybase, 0.0 );
        glDrawPixels_c( $ref->{w}, $ref->{h}, GL_RGBA, GL_UNSIGNED_BYTE, $ref->{array}->ptr() );
        # $input = undef;
    }

    #$xbase += $ref->{w};

    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.3, 0.6, 0.8, 1.0);
    
    # 通过开启混合，来避免位图的透明背景变黑问题
    glEnable(GL_BLEND);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

sub idle 
{
    sleep 0.05;
    glutPostRedisplay();
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
    glOrtho( 0.0, $w, 0.0, $h, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    state $buff;
    my $k = shift;
    glutDestroyWindow($WinID) if ( chr($k) eq 'q' );
    if ( chr($k) eq 'p' ) { $pause = !$pause; }
        
    if ( $k > 127 ) {
        if (not defined $buff) {
            printf "this is wide character: ";
            $buff = chr($k);
        } else {
            $buff .= chr($k);
            printf "%s\n", $buff;
            $input = $buff;
            $buff = undef;
        }
    }
    else
    {
        $input = chr($k);
    }
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(5, 100);
    our $WinID = glutCreateWindow("Key Input and Print");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
