=info
    Auth: 523066680
    Date: 2018-11
    
    $img->string(x => 50, y => 70, .... );
    x, y - the point to draw the text from.
    If align is 0 this is the top left of the string.  
    If align is 1 (the default) then this is the left of the string on the baseline. Required.

    如果 align => 0, 则x,y用于定位字符左上角的位置
    如果 align => 1, 则x,y用于定位字符基线的位置

    global_descent -> 全局字体下深 (基线到底部的距离)
    descent -> 当前文字的下深
    global_ascent -> 全局字体上高
    ascent -> 上高
    
    以下方法只为了兼容旧方案(有 bug)，不应该在新代码中使用
    total_width() -> New code should use display_width().
    end_offset()
    pos_width()

=cut

use utf8;
use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Data::Dumper;
use Imager;
STDOUT->autoflush(1);

our $SIZE_X = 680;
our $SIZE_Y = 500;
our $WinID;

INIT
{
    our $SIZE = 160;
    $blue = Imager::Color->new("#0000FF");
    $font = Imager::Font->new(file  => 'C:/windows/fonts/STXINGKA.TTF',
                              size  => $SIZE );

    our $TEXT = "了天ag人";
    our $bbox = $font->bounding_box( string => $TEXT );
    our $img = Imager->new( xsize=>$bbox->total_width+59, ysize=>$bbox->font_height , channels=>4 );
    our ($H, $W) = ($img->getheight(), $img->getwidth());
    printf "width: %d, height: %d\n", $W, $H;

    # 填充画布背景色
    $img->box(xmin => 0, ymin => 0, xmax => $W, ymax => $H,
            filled => 1, color => '#336699');

    my $baseline = $H - abs $bbox->global_descent;
    $img->string(
               font  => $font,
               text  => $TEXT, #or string => "..."
               x     => 0,
               y     => $H - abs $bbox->global_descent ,
               size  => $SIZE,
               color => 'gold',
               aa    => 1,     # anti-alias
               align => 1,
            );

    draw_hz_line('gray', 20, 0);
    draw_vt_line('gray', 20, 0);

    printf "%s\n", join(", ", @$bbox);

    printf "%3d baseline\n",  $baseline;
    printf "%3d start_offset\n",  $bbox->start_offset;
    printf "%3d global_descent\n",$bbox->global_descent;
    printf "%3d descent\n",       $bbox->descent;
    printf "%3d global_ascent\n", $bbox->global_ascent;
    printf "%3d ascent\n",        $bbox->ascent;
    printf "%3d font_height\n",   $bbox->font_height;
    printf "%3d text_height\n",   $bbox->text_height;

    #printf "%3d end_offset\n",    $bbox->end_offset; # not suggest to use
    printf "%3d advance_width\n", $bbox->advance_width;
    printf "%3d pos_width\n",     $bbox->pos_width;
    printf "%3d total_width\n",   $bbox->total_width; # not suggest to use
    printf "%3d display_width\n", $bbox->display_width;
    printf "%3d left_bearing\n",  $bbox->left_bearing;
    printf "%3d right_bearing\n", abs $bbox->right_bearing;

    draw_text( 0, $baseline, 16, 'white', "baseline", $img );
    draw_hz_line( 'white', $bbox->display_width, $baseline );
    #draw_hz_line( 'white', $bbox->display_width, $baseline + $bbox->start_offset );

    draw_text( 0, $baseline + abs($bbox->global_descent), 16, 'green', "global_descent", $img );
    draw_hz_line( 'green', $bbox->display_width, $baseline + abs($bbox->global_descent) - 1 );

    draw_text( 150, $baseline + abs $bbox->descent, 16, 'red', "descent", $img );
    draw_hz_line( 'red',   $bbox->display_width, $baseline + abs $bbox->descent );

    draw_text( 200, $baseline - $bbox->global_ascent+16, 16, 'red', "global_ascent", $img );
    draw_hz_line( 'red', $bbox->display_width,  $baseline - $bbox->global_ascent  );

    draw_text( 50, $baseline - $bbox->ascent, 16, 'blue', "ascent", $img );
    draw_hz_line( 'blue', $bbox->display_width, $baseline - $bbox->ascent );
    # text_height = descent + $ascent;
    #draw_hz_line( 'orange',  100,  $baseline + (abs $bbox->descent) - $bbox->text_height );


    draw_vt_line( 'red',     60, $bbox->start_offset );   # 同 left_bearing
    draw_vt_line( 'red',     50, $bbox->end_offset );     # not suggest to use
    draw_vt_line( 'blue',    80, $bbox->advance_width );  # end_offset 的取代值， 右边界
    #draw_vt_line( 'blue',    50, $bbox->total_width );   # not suggest to use
    draw_vt_line( 'yellow',  30, $bbox->left_bearing );   # 左边啤位 
    draw_vt_line( 'yellow',  30, $bbox->advance_width - $bbox->right_bearing );  #右边啤位

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

    sub draw_hz_line {
        my ($c, $len, $y) = @_;
        $img->line(color=>$c, x1=>0, x2=>$len, y1=>$y, y2=>$y );
    }

    sub draw_vt_line {
        my ($c, $len, $x) = @_;
        $img->line(color=>$c, x1=>$x, x2=>$x, y1=>0, y2=>$len );
    }

    sub draw_text {
        my ($x, $y, $size, $color, $text, $img) = @_;
        my $font = Imager::Font->new(file  => 'C:/windows/fonts/consola.ttf', size => $size) or warn "$!";
        $img->align_string(
                   font  => $font,
                   text  => $text, #or string => "..."
                   x     => $x,
                   y     => $y - 1,
                   size  => $size,
                   color => $color,
                   aa    => 1,     # anti-alias
                   valign => 'bottom', halign => 'left',
            );
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
