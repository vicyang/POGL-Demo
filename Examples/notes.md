* ### OpenGL::Array  
  在把数组指针传递给某些 opengl _c 函数的时候，应使用 $array->ptr 的形式  
  
  > ptr = $array->ptr(); # typically passed to opengl _c functions  
  > Returns a C pointer to an array object.  
  
  * ### OpenGL::Array 对象操作  
  $array->calc( ... )  
  通过逆波兰表达式对数组对象进行操作。操作对象必须是 GL_FLOAT 类型  

  使用 $value 填充数组  
  $array->calc($value);  

  使用 @values 的元素填充数组（假设分量相同）  
  $array->calc(@values);  

  
* ### 积累缓冲区/运动模糊  
  GL_LOAD  从颜色缓冲区获取图像 (通常第一次使用LOAD，叠加使用ACCUM)  
  GL_ACCUM 参数用于从颜色缓冲区获取图像并叠加  
  GL_MULT  对积累缓冲区的数据进行乘法运算  
  GL_ADD   对积累缓冲区的数据进行加法运算  
  GL_RETURN 参数，将积累缓冲区的内容写到颜色缓冲区  
  
  （在某个AMD显卡上测试没有模糊效果）  
  
* ### Untitle  
