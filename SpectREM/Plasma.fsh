
void main()
{
    // fake chromatic aberration in the stupidest way possible
    vec2 texCoordOffset = vec2(0.003, 0);
    float r = texture2D(u_texture, v_tex_coord - texCoordOffset).r;
    float g = texture2D(u_texture, v_tex_coord).g;
    float b = texture2D(u_texture, v_tex_coord + texCoordOffset).b;
    vec4 imageColor = vec4(r,g,b,1);
    
    // fake scanlines in the stupidest way possible
    vec4 scanlineColor = 1.2 * vec4(1,1,1,1) * abs(sin(v_tex_coord.y * 1000));
    
    // combine everything
    gl_FragColor = v_color_mix * imageColor * scanlineColor;


}
