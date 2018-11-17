=info
    Auth: 523066680
    Date: 2018-11
=cut

use utf8;
use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Imager;

our $SIZE_X = 620;
our $SIZE_Y = 520;
our $WinID;

INIT
{
    our $SIZE = 60;
    $blue = Imager::Color->new("#0000FF");
    $font = Imager::Font->new(file  => 'C:/windows/fonts/STXINGKA.TTF',
                              color => $blue,
                              size  => $SIZE );

    my $TEXT = "火凤燎原，火";
    my $bbox = $font->bounding_box( string => $TEXT );
    my $img = Imager->new(xsize=>$bbox->total_width, ysize=>$bbox->text_height, channels=>4);

    $img->string(
               font  => $font,
               text  => $TEXT, #or string => "..."
               x     => -$bbox->left_bearing,
               y     => 0 + $SIZE + $bbox->global_descent,     #基线偏移
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
            );

    our ($H, $W) = ($img->getheight(), $img->getwidth());
    printf "width: %d, height: %d\n", $W, $H;

    our @rasters;
    my @colors;
    for my $y ( reverse 0 .. $H-1 )
    {
        @colors = $img->getpixel(x=>[ 0 .. $W-1 ], y=>[ $y ]);
        grep { push @rasters, $_->rgba  } @colors;
    }

    our $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);
}

&Main();

sub display
{
    glClear(GL_COLOR_BUFFER_BIT);

    # my $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    # $array->assign(0, @rasters);

    glRasterPos3f( 0.0, 20.0, 0.0 );
    glutBitmapString( GLUT_BITMAP_HELVETICA_18, "Character 23");
    glDrawPixels_c( $W, $H, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

    glutSwapBuffers();
}

sub init 
{
    glClearColor(0.3, 0.6, 0.8, 1.0);
    glEnable(GL_BLEND);
    #glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

sub idle 
{
    sleep 0.1;
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
    glOrtho( 0.0, $h, 0.0, $w, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    my $key = shift;
    glutDestroyWindow($WinID) if ( lc(chr($key)) eq 'q' );
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("glBitmap");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
