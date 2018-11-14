=info
    生成能够精确覆盖的矩阵_随机填充法.pl
=cut
package RandMatrix;
use List::Util qw/shuffle sum/;

our $n = 8;    #有效行
our $m = 30;   #列

sub fill_rand_row
{
    my ($mat, $insert) = @_;
    for my $iter ( 1.. $insert )
    {
        my $row = rand( 5 );  #控制在前5行
        splice @$mat, $row, 0, [map { int(rand(2)) } (1..$m) ];
    }
}

sub create_mat
{
    my $mat = shift;
    $$mat = [ map { [map { "0" } (1 .. $m)] } (1 .. $n) ];

    my @rands = shuffle ( 0 .. $m-1 );
    my $r;
    my $c;
    for my $times ( 1 .. $m )
    {
        $r = int(rand($n));
        $c = shift @rands;
        $$mat->[$r][$c] = 1;
    }
}

sub dump_mat
{
    my $ref = shift;
    for my $r ( 0 .. $#$ref )
    {
        printf "%s, => %d\n", join(",", @{$ref->[$r]} ), sum( @{$ref->[$r]} ) ;
    }
}

1;