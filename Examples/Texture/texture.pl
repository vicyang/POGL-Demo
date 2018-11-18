#!/usr/local/bin/perl
#
#          texture
#
#  This program demonstrates texture mapping  
#  An image file (wolf.ppm) is read in as the texture
#  then packed into a C array format and given to glTexImage2D 

use OpenGL qw/ :all /;
use OpenGL::Config;

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    our $spin=0.0;
}

main();

sub read_ascii_ppm
{
    # reads in an ascii ppm format image file
    # returns the list (width,height,packed rgb image data)
    #
    # I'm not to familiar with the ppm file format 
    # this subroutine may not work for all valid ppm files
    #
    local($file) = @_;
    local($w,$h,$image);
    local(@image);

    open(PPM,"<$file") || die "cant open $file";
    (<PPM>);          # the first line is just a header: "P3"
    (<PPM>);          # The second line is a comment 
    ($_=<PPM>);         # the 3rd line gives width and height

    m/(\d+)\s+(\d+)/; 
    $w=$1 ; $h=$2 ;
    ($w>=64 && $h>=64 && $w<10000 && $h<10000) || die "strange sizes $w,$h";
    ($_=<PPM>);        # 4th line is depth (should be 255)
    (/255/) || die " improper depth $_";
    $image="";
    
    while(<PPM>) {
        chop;
        $image .= $_ . " ";
    }

    @image=split(/\s+/,$image);
    $size=$w*$h*3;
    ($size == $#image +1) || die "array length $#image +1  differs from expected size $size" ; 
    $image=pack("C$size",@image);
    close(PPM);
    
    if ($file =~ s/\.ppm$/.bin/ and not -r $file) 
    {
        print STDERR "Writing binary image data '$file'.\n";
        open BIN, "> $file" || die "cant open '$file': $!";
        binmode BIN;
        print BIN pack 'N N a*', $w, $h, $image;
        close BIN or die "error closing '$file': $!";
    }
    ($w,$h,$image);
}

sub read_bin_image 
{
    # reads in a binary image file
    # returns the list (width,height,packed rgb image data)
    #
    # I'm not to familiar with the ppm file format 
    # this subroutine may not work for all valid ppm files
    #
    my($file) = @_;
    my($w,$h,$image);
    my(@image);
    open(BIN,"<$file") || die "cant open '$file': $!";
    binmode BIN;
    my $data = do {local $/; <BIN>};
    close BIN or die "error closing '$file': $!";
    return unpack 'N N a*', $data;
}

sub display
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity ();
    glTranslatef(0.0, 0.0, -2.6);

    glPushMatrix();
    glRotatef($spin,0,1,0);
    glRotatef($spin,0,0,1);
    glBegin(GL_QUADS);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, -1.0, 0.0);
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, 1.0, 0.0);
    glTexCoord2f(1.0, 0.0); glVertex3f(1.0, 1.0, 0.0);
    glTexCoord2f(1.0, 1.0); glVertex3f(1.0, -1.0, 0.0);

    glPopMatrix();
    glEnd();
    glFlush();
    glutSwapBuffers();
}


sub idle 
{
    sleep 0.05;
    $spin=$spin+1.0;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glPointSize(2.0);

    glShadeModel (GL_FLAT);
 
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    #$file = "wolf.ppm";
    #-r $file or $file = "examples/$file";
    #($w,$h,$image)=&read_ascii_ppm($file);

    $file = "wolf.bin";
    -r $file or $file = "examples/$file";
    ($w,$h,$image) = &read_bin_image($file);

    glTexImage2D_s(GL_TEXTURE_2D, 0, 3, $w,$h, 0, GL_RGB, GL_UNSIGNED_BYTE, $image);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
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
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_MULTISAMPLE );
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