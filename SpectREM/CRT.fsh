
vec2 radialDistortion(vec2 pos, float distortion)
{
    vec2 cc = pos - 0.465;
    float dist = dot(cc, cc) * distortion;
    return (pos + cc * (1.3 + dist) * dist);
}

void main()
{
    vec2 texCoord = radialDistortion(v_tex_coord, u_distortion);
    gl_FragColor = texture2D(u_texture, texCoord);
}


//vec2 texCoordOffset = vec2(0.002, 0);

//float r = texture2D(u_texture, texCoord - texCoordOffset).r;
//float g = texture2D(u_texture, texCoord).g;
//float b = texture2D(u_texture, texCoord + texCoordOffset).b;
//vec4 imageColor = vec4(r,g,b,1);
//
//vec4 c = v_color_mix * imageColor;
//
//
//vec4 c1 = vec4(0,0,0,1);
//
////    if (mod(floor(texCoord.y * size.y / 2.0), 2.0) == 0.0)
////        c1 = vec4(c.r, c.g, c.b, 0.1);
////    else
//c1 = vec4(c.r, c.g, c.b, 1.0);
