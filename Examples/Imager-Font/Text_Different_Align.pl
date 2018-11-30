=info
    Auth: 523066680
    Date: 2018-11
=cut

use utf8;
use strict;
use Encode;
use Time::HiRes qw/time sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Data::Dumper;
use Imager;
STDOUT->autoflush(1);

INIT
{
    our $SIZE_X = 800;
    our $SIZE_Y = 400;
    our $WinID;
    our $font_size = 26;
    our $box_size = $font_size * 2;

    our ($font_size);
    our $font = Imager::Font->new(file  => encode('gbk', 'C:/windows/fonts/msyh.ttf'), #STXINGKA.TTF
                              size  => $font_size );
    sub font_align_test
    {
        our ($font, $font_size);
        my ( $char, $halign, $valign ) = @_;

        my $bbox = $font->bounding_box( string => $char );
        my $img = Imager->new(xsize=>$box_size , 
                              ysize=>$box_size , channels=>4);

        my $h = $img->getheight();
        my $w = $img->getwidth();

        # 填充画布背景色
        $img->box(xmin => 0, ymin => 0, xmax => $w, ymax => $h,
                filled => 1, color => '#336699');

        $img->align_string(
                   font  => $font,
                   text  => $char,
                   x     => $w/2.0,
                   y     => $h/2.0,
                   size  => $font_size,
                   color => 'white',
                   aa    => 1,     # anti-alias
                   valign => $valign, halign => $halign,
                   align => 0,
                );

        $img->line(color=>'orange', x1=>0, x2=>$w, y1=>$h/2.0, y2=>$h/2.0 );
        $img->line(color=>'orange', x1=>$w/2.0, x2=>$w/2.0, y1=>0, y2=>$h );

        my $array;
        my @rasters;
        my @colors;
        for my $y ( reverse 0 .. $h - 1 )
        {
            @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
            grep { push @rasters, $_->rgba  } @colors;
        }

        $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
        $array->assign(0, @rasters);

        glDrawPixels_c( $w, $h, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );
    }

    sub draw_hz_line
    {
        our ($img);
        my ($c, $len, $y) = @_;
        $img->line(color=>$c, x1=>0, x2=>$len, y1=>$y, y2=>$y );
    }

    sub draw_vt_line
    {
        our ($img);
        my ($c, $len, $x) = @_;
        $img->line(color=>$c, x1=>$x, x2=>$x, y1=>0, y2=>$len );
    }

    sub draw_text
    {
        my ($size, $color, $text) = @_;
        my $font = Imager::Font->new(file  => 'C:/windows/fonts/consola.ttf', size => $size) or warn "$!";
        my $bbox = $font->bounding_box( string => $text );
        my $img = Imager->new( xsize=>$bbox->total_width, ysize=>$bbox->text_height, channels=>4 );
        my $h = $img->getheight();
        my $w = $img->getwidth();

        $img->align_string(
                   font  => $font,
                   text  => $text, #or string => "..."
                   x     => 0.0,
                   y     => $h,
                   size  => $size,
                   color => $color,
                   aa    => 1,     # anti-alias
                   valign => 'bottom', halign => 'left',
            );

        my $array;
        my @rasters;
        my @colors;
        for my $y ( reverse 0 .. $h - 1 )
        {
            @colors = $img->getpixel( x => [ 0 .. $w - 1 ], y => [$y] );
            grep { push @rasters, $_->rgba  } @colors;
        }

        $array = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
        $array->assign(0, @rasters);

        glDrawPixels_c( $w, $h, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );
    }
}

&Main();

sub display
{
    our ($font_size, $box_size);
    glClear(GL_COLOR_BUFFER_BIT);

    # 备注
    glRasterPos3f( $box_size/2.0, 100.0, 0.0 );
    draw_text( 18, 'white', "align_string, mount point: x => w/2.0, y => h/2.0 " );
    glRasterPos3f( $box_size/2.0, $box_size+2.0, 0.0 );
    draw_text( 18, 'white', "hz:" );
    glRasterPos3f( $box_size/2.0, $box_size+20.0, 0.0 );
    draw_text( 18, 'white', "vt:" );


    my $offset = 1.0;
    for my $hz ( 'left', 'right', 'center' )
    {
        for my $vt ( 'top', 'bottom', 'center' )
        {
            glRasterPos3f( ($box_size+20.0) * $offset, 0.0, 0.0 );
            font_align_test( "g", $hz, $vt );
            glRasterPos3f( ($box_size+20.0) * $offset, $box_size+2.0, 0.0 );
            draw_text( 18, 'gold', $hz );
            glRasterPos3f( ($box_size+20.0) * $offset, $box_size+20.0, 0.0 );
            draw_text( 18, 'gold', $vt );
            $offset++;
        }
    }

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
    glOrtho( 0.0, $w, -100.0, $h-100.0, 0.0, $fa*2.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    our ($WinID);
    my $key = shift;
    glutDestroyWindow($WinID) if ( lc(chr($key)) eq 'q' );
}

sub Main 
{
    our ($SIZE_X, $SIZE_Y);
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize($SIZE_X, $SIZE_Y);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("Imager align_string");
    &init();
    glutDisplayFunc(\&display);
    glutKeyboardFunc(\&hitkey);
    glutReshapeFunc(\&reshape);
    glutIdleFunc(\&idle);
    glutMainLoop();
}
