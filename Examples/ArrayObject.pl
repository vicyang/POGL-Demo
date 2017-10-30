use feature 'state';
use feature 'say';
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

    my @verts = (1,2,3, 4,5,6);
    my $array  = OpenGL::Array->new_list( GL_FLOAT, @verts );

    $array->calc('3,*', '2,+', 1.2 );
    print_array( $array );

    ' 还原 ';
    $array->calc(@verts);
    $array->calc('2,colget','','');    ' 获取 v[2] 替换 v[0] ';
    print_array( $array );

    $array->calc('9,2,colset','','');  ' 设置 v[2] 为9，并且替换到 v[0] ';
    print_array( $array );

    ' 还原 ';
    $array->calc(@verts);
    $array->calc('1,2,rowget','','');     ' 获取 row[1] col[2] 元素替换到 v[0] ';
    print_array( $array );

    say 'S0 from S0, and cell[1,2] = 99 ';
    $array->calc(@verts);
    $array->calc('99,1,2,rowset,0,colget','',''); 
    print_array( $array );

    sub print_array
    {
        grep { 
            printf "%.2f,", $_ ;
            print "\n" if $n++ % 3 == 0 
        }
        ${_[0]}->retrieve();
        print "\n";
    }
}

