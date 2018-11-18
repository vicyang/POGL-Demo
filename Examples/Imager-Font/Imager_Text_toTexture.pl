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

our $SIZE_X = 620;
our $SIZE_Y = 520;
our $WinID;
our $pause = 0;

INIT
{
    use Imager;
    our $SIZE = 120;
    our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/STXINGKA.TTF'), #STXINGKA.TTF
                              size  => $SIZE );
    our $bbox = $font->bounding_box(string=>"");

    our @TEXT = split("", "十步杀一人，千里不留行。事了拂衣去，深藏身与名。" );
    our @TEXT_DATA = map { {} } ( 0 .. $#TEXT );

    for my $id ( 0 .. $#TEXT )
    {
        get_text_map( $TEXT[$id] , $TEXT_DATA[$id] );
        printf "%d %d\n", $TEXT_DATA[$id]->{h}, $TEXT_DATA[$id]->{w};
    }
}



Main();

sub get_text_map
{
    our ($font, $SIZE);
    my ( $char, $ref ) = @_;

    my $bbox = $font->bounding_box( string => $char );
    my $img = Imager->new(xsize=>$bbox->display_width+$bbox->left_bearing, 
                          ysize=>$bbox->font_height, channels=>4);

    my $h = $img->getheight();
    my $w = $img->getwidth();

    $img->string(
               font  => $font,
               text  => $char,
               x     => 0,
               y     => $h + $bbox->global_descent,   # 基线 = 总高度 - 下沉
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
            );

    $ref->{h} = $h, $ref->{w} = $w;

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $h - 1 )
    {
        @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
        grep { push @rasters, $_->rgba  } @colors;
    }

    $ref->{array} = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $ref->{array}->assign(0, @rasters);

}

sub display
{
    our ($bbox);
    state $iter = -1;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
    glRotatef($spin, 0.0, 1.0, 0.0);
    #glRotatef($spin, 0.0, 0.0, 0.0);
    glColor4f(0.3, 0.6, 0.8, 1.0);
    glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.0);  glVertex3f( 0.0, 0.0, 0.0);
        glTexCoord2f(1.0, 0.0);  glVertex3f(80.0, 0.0, 0.0);
        glTexCoord2f(1.0, 1.0);  glVertex3f(80.0, 80.0, 0.0);
        glTexCoord2f(0.0, 1.0);  glVertex3f(0.0, 80.0, 0.0);
    glEnd();

    glTranslatef(0.0, 0.0, -50.0);
    glColor4f(0.3, 0.6, 0.8, 1.0);
    glBegin(GL_QUADS);
        glTexCoord2f(0.0, 0.0);  glVertex3f( 0.0, 0.0, 0.0);
        glTexCoord2f(1.0, 0.0);  glVertex3f(80.0, 0.0, 0.0);
        glTexCoord2f(1.0, 1.0);  glVertex3f(80.0, 80.0, 0.0);
        glTexCoord2f(0.0, 1.0);  glVertex3f(0.0, 80.0, 0.0);
    glEnd();
    glPopMatrix();

    my $ref = $TEXT_DATA[0];
    glRasterPos3f( -200.0 , -100.0, 0.0 );
    glDrawPixels_c( $ref->{w}, $ref->{h}, GL_RGBA, GL_UNSIGNED_BYTE, $ref->{array}->ptr() );

    $iter ++ if ($iter < $#TEXT and $pause == 0);
    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.0, 0.0, 0.0, 0.5);
    
    # 通过开启混合，来避免位图的透明背景变黑问题
    glEnable(GL_BLEND);
    #glEnable(GL_DEPTH_TEST);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    #glBlendFunc(GL_SRC_COLOR, GL_DST_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    my $data = {};
    get_text_map( "CH" , $data );
    my $ref = $TEXT_DATA[1];
    glTexImage2D_c(GL_TEXTURE_2D, 0, GL_RGBA, $ref->{w}, $ref->{h}, 0, GL_RGBA, GL_UNSIGNED_BYTE, $ref->{array}->ptr() );

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    #glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    #此函数若使用不当，会导致无法正常显示某些位深的图片
    
    glEnable(GL_TEXTURE_2D);
}

sub idle 
{
    sleep 0.02;
    $spin += 2.0;
    glutPostRedisplay();
}

sub reshape 
{
    my ($w, $h) = (shift, shift);
    #Same with screen size
    my $w_half = $w/2.0;
    my $h_half = $h/2.0;
    my $fa = 200.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho( -$w_half, $w_half, -$h_half, $h_half, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    my $key = shift;
    glutDestroyWindow($WinID) if ( lc(chr($key)) eq 'q' );
    if ( chr($key) eq 'p' ) { $pause = !$pause; }
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(5, 100);
    our $WinID = glutCreateWindow("Imager::Font");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
