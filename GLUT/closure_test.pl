use Modern::Perl;
use OpenGL qw/:all/;
use OpenGL::Config;

{
    package subwin1;
    use Modern::Perl;

    our $foo = 1;
    my $bar = 20;
    say $subwin1::foo;

    sub test
    {
        $foo++;
        print $foo;
        print $bar;
    }
}

subwin1::test();
