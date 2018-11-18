闭包变量访问问题  

```perl
&main();

{
    package subwin1;
    use Modern::Perl;
    use OpenGL qw/:all/;
    use OpenGL::Config;
    my $iter = 0.0;

    sub display
    {
        # visit $iter 
    }
}

sub main { ... DisplayFunc( \&subwin1::display ) }
```
  
display 内部无法访问 $iter，原因是调用 main 后进入事件循环，my $iter = 0.0; 没有被执行  

将 &main(); 放在package块之后即可。  
