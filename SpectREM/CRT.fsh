void main()
{
    // fake chromatic aberration in the stupidest way possible
    vec2 texCoordOffset = vec2(0.002, 0);
    float r = texture2D(u_texture, v_tex_coord - texCoordOffset).r;
    float g = texture2D(u_texture, v_tex_coord).g;
    float b = texture2D(u_texture, v_tex_coord + texCoordOffset).b;
    vec4 imageColor = vec4(r,g,b,1);
    
    vec4 c = v_color_mix * imageColor;
    
//    if (mod(floor(v_tex_coord.y * size.y / 2.0), 2.0) == 0.0)
//        gl_FragColor = vec4(c.r, c.g, c.b, 0.1);
//    else
        gl_FragColor = vec4(c.r, c.g, c.b, 1.0);
}
