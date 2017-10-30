use feature 'state';
use IO::Handle;
use Time::HiRes qw/sleep/;
use OpenGL qw/ :all /;
use OpenGL::Config;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 700;
    my $n = 1;

    my $array  = OpenGL::Array->new_list( GL_FLOAT, 1,2,3, 4,5,6 );
    # my $o2 = OpenGL::Array->new_list(GL_FLOAT, 7, 8 ,9,  10, 11, 12);
    #$verts->calc("1.0", "3,*", "2,+");
    $array->calc('3,*', '2,+', 1.2 );
    grep { printf "%.2f ", $_ ; print "\n" if $n++ % 3 == 0 } $array->retrieve();

}

