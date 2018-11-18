=info
    Auth: 523066680
    Date: 2018-11
    
    $img->string(x => 50, y => 70, .... );
    x, y - the point to draw the text from.
    If align is 0 this is the top left of the string.  
    If align is 1 (the default) then this is the left of the string on the baseline. Required.

    如果 align => 0, 则x,y用于定位字符左上角的位置
    如果 align => 1, 则x,y用于定位字符基线的位置

    global_descent -> 全局字符的底部延伸距离 (基线到底部的距离)
    descent -> 当前文字的底部延伸距离
    global_ascent -> 
    ascent -> 
    

=cut

use utf8;
use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Data::Dumper;
use Imager;
STDOUT->autoflush(1);

our $SIZE_X = 620;
our $SIZE_Y = 520;
our $WinID;

INIT
{
    our $SIZE = 120;
    $blue = Imager::Color->new("#0000FF");
    $font = Imager::Font->new(file  => 'C:/windows/fonts/STXINWEI.TTF',  #STXINGKA.TTF
                              color => $blue,
                              size  => $SIZE );

    our $TEXT = "一天acfg";
    our $bbox = $font->bounding_box( string => $TEXT );
    our $img = Imager->new( xsize=>$bbox->total_width+59, ysize=>$SIZE, channels=>4 );
    our ($H, $W) = ($img->getheight(), $img->getwidth());
    printf "width: %d, height: %d\n", $W, $H;
    $img->box(xmin => 0, ymin => 0, xmax => $W, ymax => $H,
            filled => 1, color => '#336699');

    my $baseline = $SIZE - abs ($bbox->global_descent - $bbox->descent);
    my ($left, $top, $right, $bottom) = 
    $img->align_string(
            text => $TEXT,
            x => 0, y => 0,
            halign =>'left', valign => 'top',
            font => $font,
            color => 'gold',
            aa => 1,
        );

    printf "x:%d\n",abs ($global_descent - $descent);

    draw_hz_line('gray', 20, 0);
    draw_vt_line('gray', 20, 0);

    #printf "%3d baseline\n",  $baseline;
    printf "%3d start_offset\n",  $bbox->start_offset;
    printf "%3d global_descent\n",$bbox->global_descent;
    printf "%3d descent\n",       $bbox->descent;
    printf "%3d global_ascent\n", $bbox->global_ascent;
    printf "%3d ascent\n",        $bbox->ascent;
    printf "%3d font_height\n",   $bbox->font_height;
    printf "%3d text_height\n",   $bbox->text_height;

    printf "%3d end_offset\n", $bbox->end_offset;
    printf "%3d total_width\n", $bbox->total_width;
    printf "%3d display_width\n", $bbox->display_width+1;
    printf "%3d left_bearing\n", $bbox->left_bearing;
    printf "%3d right_bearing\n", abs $bbox->right_bearing-1;

    #draw_hz_line( 'white', $bbox->total_width,  $bbox->start_offset );
    draw_hz_line( 'green', $bbox->total_width, $H-abs($bbox->global_descent) );
    draw_hz_line( 'red', $bbox->total_width,  $H - abs $bbox->descent );
    draw_hz_line( 'red', $bbox->total_width,  $H - $bbox->global_ascent  );
    draw_hz_line( 'blue', $bbox->total_width, $H - $bbox->ascent );
    draw_hz_line( 'green', $bbox->total_width, $bbox->text_height );
    #draw_hz_line( 'green', $bbox->total_width, $bbox->font_height-6 );

    # draw_vt_line( 'red', $bbox->total_width, $bbox->end_offset );
    # draw_vt_line( 'blue', $bbox->total_width, $bbox->total_width );
    # draw_vt_line( 'green', $bbox->total_width, $bbox->display_width+1 );
    # draw_vt_line( 'orange', $bbox->total_width, $bbox->left_bearing );
    # draw_vt_line( 'yellow', $bbox->total_width, abs $bbox->right_bearing-1 );

    printf "%d %d\n", $bbox->end_offset, $bbox->global_descent;
    printf join(", ", @$bbox);

    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $H-1 )
    {
        @colors = $img->getpixel(x=>[ 0 .. $W-1 ], y=>[ $y ]);
        grep { push @rasters, $_->rgba  } @colors;
    }

    our $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    $array->assign(0, @rasters);

    sub draw_hz_line
    {
        my ($c, $len, $y) = @_;
        $img->line(color=>$c, x1=>0, x2=>$len, y1=>$y, y2=>$y );
    }

    sub draw_vt_line
    {
        my ($c, $len, $x) = @_;
        $img->line(color=>$c, x1=>$x, x2=>$x, y1=>0, y2=>$len );
    }
}

&Main();

sub display
{
    glClear(GL_COLOR_BUFFER_BIT);

    glRasterPos3f( 0.0, 100.0, 0.0 );
    glutBitmapString( GLUT_BITMAP_HELVETICA_18, "Char");
    glDrawPixels_c( $W, $H, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

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
