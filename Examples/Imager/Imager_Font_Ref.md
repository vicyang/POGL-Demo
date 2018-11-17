* 关于字符的基线、啤线参考图
  http://www.myfirstfont.com/glossary.html

bounding_box()

    Returns the bounding box for the specified string. Example:

    my ($neg_width,
        $global_descent,
        $pos_width,
        $global_ascent,
        $descent,
        $ascent,
        $advance_width,
        $right_bearing) = $font->bounding_box(string => "A Fool");

Imager::Font::BBox

# methods
my $start = $bbox->start_offset;
my $left_bearing = $bbox->left_bearing;
my $right_bearing = $bbox->right_bearing;
my $end = $bbox->end_offset;
my $gdescent = $box->global_descent;
my $gascent = $bbox->global_ascent;
my $ascent = $bbox->ascent;
my $decent = $bbox->descent;
my $total_width = $bbox->total_width;
my $fheight = $bbox->font_height;
my $theight = $bbox->text_height;
my $display_width = $bbox->display_width;