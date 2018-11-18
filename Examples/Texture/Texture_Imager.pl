=info
    By 523066680/vicyang
=cut

use Imager;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Time::HiRes qw/sleep/;
STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    our $spin=0.0;
}

sub read_image
{
    my ($file, $ref) = @_;
    my $img = Imager->new();
    $img->read(file => $file) or die "Cannot load $file: ", $img->errstr;

    my ($H, $W) = ( $img->getheight(), $img->getwidth() );
    printf "width: %d, height: %d\n", $W, $H;

    my $array;
    my @rasters;
    my @colors;
    for my $y ( reverse 0 .. $H-1 )
    {
        @colors = $img->getpixel( x=>[ 0 .. $W-1 ], y=>[ $y ]);
        grep { push @rasters, $_->rgba  } @colors;
    }

    $$ref = OpenGL::Array->new( scalar( @rasters ), GL_UNSIGNED_BYTE ); 
    ${$ref}->assign(0, @rasters);

    return ($H, $W, $array );
}

main();

sub display
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity ();
    glTranslatef(0.0, 0.0, -2.6);

    glPushMatrix();
    glRotatef($spin, 0.0, 1.0, 0.0);
    glRotatef($spin, 0.0, 0.0, 1.0);
    glColor4f(0.3, 0.6, 0.8, 0.1);
    glBegin(GL_QUADS);
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, -1.0, 0.0);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, 1.0, 0.0);
        glTexCoord2f(1.0, 0.0); glVertex3f(1.0, 1.0, 0.0);
        glTexCoord2f(1.0, 1.0); glVertex3f(1.0, -1.0, 0.0);
    glEnd();
    glPopMatrix();

    glPushMatrix();
    glTranslatef(-1.0, -1.0, 0.0);
    glRotatef(-$spin, 0.0, 1.0, 0.0);
    glRotatef($spin, 0.0, 0.0, 1.0);
    glColor4f(0.3, 0.6, 0.8, 0.0);
    glBegin(GL_QUADS);
        glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, -1.0, 0.0);
        glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, 1.0, 0.0);
        glTexCoord2f(1.0, 0.0); glVertex3f(1.0, 1.0, 0.0);
        glTexCoord2f(1.0, 1.0); glVertex3f(1.0, -1.0, 0.0);
    glEnd();
    glPopMatrix();


    glutSwapBuffers();
}


sub idle 
{
    sleep 0.01;
    $spin = $spin+1.0;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 0.0);

    #glShadeModel (GL_SMOOTH);
 
    glEnable(GL_BLEND);
    #glEnable(GL_DEPTH_TEST);
    
    glDepthFunc(GL_LESS);
    glBlendFunc(GL_SRC_COLOR, GL_DST_ALPHA);
    # glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    my $array;
    my ($h, $w, $image) = read_image( "png_24bit.png", \$array );

    printf "%d %d\n", $w, $h;
    glTexImage2D_c(GL_TEXTURE_2D, 0, GL_RGBA, $w, $h, 0, GL_RGBA, GL_UNSIGNED_BYTE, $array->ptr() );

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    #glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    #此函数若使用不当，会导致无法正常显示某些位深的图片
    
    glEnable(GL_TEXTURE_2D);
}

sub reshape
{
    my ($w, $h) = (shift, shift);
    my $vthalf = $w/2.0;
    my $hzhalf = $h/2.0;
    my $fa = 100.0;

    glViewport(0, 0, $w, $h);
=temp
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$vthalf, $vthalf, -$hzhalf, $hzhalf, 0.0, $fa*2.0); 
    #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
=cut

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(60.0, 1.0 , 1.0, 30.0);

    glMatrixMode(GL_MODELVIEW);

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
    our $MAIN;

    glutInit();
    glutInitDisplayMode( GLUT_RGBA | GLUT_DOUBLE   );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("Texture");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}