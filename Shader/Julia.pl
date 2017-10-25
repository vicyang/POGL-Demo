=info
    Auth:523066680
    Date:2017-07
    https://www.shadertoy.com/view/ld2fzw

    按 '[' 和 ']' 调整阀值，按 - 和 = 调整迭代深度
    空格键 - 暂停/继续
    q or Q - 退出
=cut

use OpenGL qw/ :all /;
use OpenGL::Config;
use OpenGL::Shader;
use Time::HiRes 'sleep';
use feature 'state';
use IO::Handle;
STDOUT->autoflush(1);

our $shdr;

our $ang = 0.0;
our $iter = 250.0;
our $test = 1000.0;
our $scale = 100.0;
our ($cx, $cy);
our ($movex, $movey) = (0.0, 0.0);

our $uTest;
our $uIter;
our $uScale;
our $uMV;
our $uC;

our $PAUSE = 0;
our $FULLSCREEN = 0;

&Main();

sub display 
{
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glutSwapBuffers();
}

sub idle 
{
    sleep 0.03;

    $ang += 0.01 if ($PAUSE == 0);

    #将 cx cy 乘以不同的倍率，会得到不同的效果
    $cx = cos($ang);
    $cy = sin($ang);

    $shdr->SetVector('uC', $cx, $cy);
    glutPostRedisplay();
}

sub init 
{
    our $shdr;

    glClearColor(0.0, 0.0, 0.0, 1.0);
    $shdr = new OpenGL::Shader('GLSL');
    my $ver = $shdr->GetVersion();
    my $stat = $shdr->Load( frag_Shader(), vert_Shader() );
    $shdr->Enable();

    #如果 shader 编译不成功，错误信息会返回到 $stat
    print "$stat $ver\n";
    glPointSize(480.0);
    
    # $uTest = $shdr->Map('uTest');
    # $uIter = $shdr->Map('uIter');
    # $uScale = $shdr->Map('uScale');
    # $uMV = $shdr->Map('uMove');
    # $uC = $shdr->Map('uC');

    $stat = $shdr->SetVector('uTest', $test);
    $stat = $shdr->SetVector('uIter', $iter);
    $stat = $shdr->SetVector('uScale', $scale);
    $stat = $shdr->SetVector('uMove', $movex, $movey);
    $stat = $shdr->SetVector('uC', $cx, $cy);
}

sub reshape
{
	my ($width, $height) = @_;
	glViewport(0.0, 0.0, $width, $height);
	$stat = $shdr->SetVector('uScreenSize', $width, $height);
	glutPostRedisplay();
}

sub hitkey 
{
    my $key = shift;
    my $char = chr($key);

    if ( lc($char) eq 'q' ) { glutDestroyWindow($WinID); return; } 
    elsif ($char eq '[')  { $test -= $test * 0.1 if ( $test > 0.01 ) }
    elsif ($char eq ']')  { $test += $test * 0.1 }
    elsif ($char eq '9')  { $iter -= $iter*0.1 if ( $iter > 1.0 ) }
    elsif ($char eq '0')  { $iter += $iter*0.1  }
    elsif ($char eq '-')  { $scale -= $scale*0.05 if ( $scale > 1.0 ) }
    elsif ($char eq '=')  { $scale += $scale*0.05  }
    elsif ($char eq 'w')  { $movey -= 10.0/$scale }
    elsif ($char eq 's')  { $movey += 10.0/$scale }
    elsif ($char eq 'a')  { $movex -= 10.0/$scale }
    elsif ($char eq 'd')  { $movex += 10.0/$scale }
    elsif ($char eq ' ')  { $PAUSE = 1 - $PAUSE }
    elsif ($char eq 'f')  {

        $FULLSCREEN = 1-$FULLSCREEN; 
        if ( $FULLSCREEN ) { glutFullScreen()      }
        else               { glutLeaveFullScreen() }
    }
 
    printf("test: %.2f, iter: %.2f, scale: %.2f\n", 
        $test, $iter, $scale );

    $shdr->SetVector('uTest', $test);
    $shdr->SetVector('uIter', $iter);
    $shdr->SetVector('uScale', $scale);
    $shdr->SetVector('uMove', $movex, $movey);
}

sub mouse
{
    my ($btn, $state, $x, $y) = @_;

    if ($btn == 0 and $state == 1)
    {
    }
    elsif ( $btn == 2 and $state == 1 )
    {
    }

    glutPostRedisplay();
}

sub passive_motion
{
    my ($x, $y) = @_;
    #$shdr->SetVector('uMove', $movex+($x-250.0)/$scale, $movey-($y-250.0)/$scale);
}

sub mouse_wheel
{
    my ($unknow, $state, $x, $y) = @_;
    # state = 1 or -1

    if ($state == 1)
    {
        $scale += $scale*0.1;
    }
    else
    {
        $scale -= $scale*0.1;
    }

    $shdr->SetVector('uScale', $scale);
    glutPostRedisplay();
}

sub Main 
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE );
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(1,1);
    our $WinID = glutCreateWindow("title");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutMouseFunc(\&mouse);
    glutPassiveMotionFunc(\&passive_motion);
    glutMouseWheelFunc(\&mouse_wheel);
    glutIdleFunc(\&idle);
    glutMainLoop();
}

sub frag_Shader
{
    return '
    uniform float uTest;
    uniform float uIter;
    uniform float uScale;
    uniform vec2 uMove;
    uniform vec2 uC;
    uniform vec2 uScreenSize;

    vec2 pow_complex(vec2 Z, vec2 C, int times)
    {
        int lv = 1;
        vec2 uZ;
        vec2 tZ = Z;

        while ( lv++ < times )
        {
            uZ.x = tZ.x*tZ.x - tZ.y * tZ.y;
            uZ.y = tZ.y*tZ.x * 2.0;
            tZ = uZ;
        }

        return uZ + C;
    }

    void main(void)
    {
        vec2 coord = (gl_FragCoord.xy - uScreenSize/2.0) / uScale + uMove;

        vec4 color;
        vec2 C = uC;
        vec2 Z = coord.xy;

        int iterations = 0;
        int max_iterations = int(uIter);

        float rate;
        float threshold_squared = uTest;

        while ( (iterations < max_iterations) && (dot(Z, Z) < threshold_squared) )
        {
            Z = pow_complex(Z, C, 2);
            iterations++;
        }

        if (iterations == max_iterations)
        {
            color = vec4(0.3, 0.1, 0.1, 1.0);
        }
        else
        {
            rate =  float(iterations)/float(max_iterations)*20.0;
            //color = vec4(sin(rate), sin(rate), rate, 1.0);
            color = vec4(rate, smoothstep(exp(Z.x), 0.0, 0.5), rate, 1.0);
        }

        gl_FragColor = color;
    }
    '
}

sub vert_Shader
{
    return '
    #version 330
	void main(void)
	{
	    vec4 vertices[] = vec4[]
	        (
	            vec4( 1.0, -1.0, 1.0, 1.0),
	            vec4(-1.0, -1.0, 1.0, 1.0),
	            vec4( 1.0,  1.0, 1.0, 1.0),

	            vec4(-1.0, -1.0, 1.0, 1.0),
	            vec4(-1.0, 1.0, 1.0, 1.0),
	            vec4( 1.0,  1.0, 1.0, 1.0)
	        );

	    gl_Position = vertices[gl_VertexID];
	}
    ';
}