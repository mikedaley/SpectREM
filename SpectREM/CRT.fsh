// Curve the output based on the distortion value passed in
vec2 radialDistortion(vec2 pos, float distortion)
{
    vec2 cc = pos - 0.465;
    float dist = dot(cc, cc) * distortion;
    return (pos + cc * (1.3 + dist) * dist);
}

vec3 colorCorrection(vec3 color, float saturation, float contrast, float brightness)
{
    const vec3 meanLuminosity = vec3(0.5, 0.5, 0.5);
    const vec3 rgb2greyCoeff = vec3(0.2126, 0.7152, 0.0722);
    vec3 brightened = color * brightness;
    vec3 intensity = dot(brightened, rgb2greyCoeff);
    vec3 saturated = mix(vec3(intensity), brightened, saturation);
    vec3 contrasted = mix(meanLuminosity, saturated, contrast);
    return contrasted;
}

void main()
{
    vec2 texCoord = radialDistortion(v_tex_coord, u_distortion);
    vec4 finalColor = vec4(colorCorrection(texture2D(u_texture, texCoord).rgb, u_saturation, u_contrast, u_brightness), 1);
    gl_FragColor = finalColor;
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



//vec3 c=vec3(texture2D(sam,tex0));
//
//vec3 i=vec3(dot(c,lc));
//
//vec3 sc=mix(i,c,saturation);
//vec3 cc=mix(al,sc,contrast)+vec3(brightness);
//
//gl_FragColor=vec4(cc,1);
