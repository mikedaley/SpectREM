//
//
// Original shader by Ethan Jennings and is available at the following link: https://www.shadertoy.com/view/ldXGW4
//
// Noise generation functions borrowed from:
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl
//
// Updates made my: Mike Daley on 24th January 2017
//

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
    
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

float staticV(vec2 texCoord, float time) {
    float staticHeight = snoise(vec2(9.0,time * 1.2 + 3.0)) * 0.3 + 5.0;
    float staticAmount = snoise(vec2(1.0,time * 1.2 - 6.0)) * 0.1 + 0.3;
    float staticStrength = snoise(vec2(-9.75, time * 0.6- 3.0)) * 2.0 + 2.0;
    return (1.0 - step(snoise(vec2(5.0 * pow(time, 2.0) + pow(texCoord.x * 7.0, 1.2), pow((mod(time, 100.0) + 100.0) * texCoord.y * 0.3 + 3.0, staticHeight))), staticAmount)) * staticStrength;
}

vec2 radialDistortion(vec2 pos, float distortion)
{
    vec2 cc = pos - vec2(0.5, 0.5);
    float dist = dot(cc, cc) * distortion;
    return (pos + cc * (0.5 + dist) * dist);
}

vec3 colorCorrection(vec3 color, float saturation, float contrast, float brightness)
{
    const vec3 meanLuminosity = vec3(0.5, 0.5, 0.5);
    const vec3 rgb2greyCoeff = vec3(0.2126, 0.7152, 0.0722);    // Updated greyscal coefficients for sRGB and modern TVs
    
    vec3 brightened = color * brightness;
    float intensity = dot(brightened, rgb2greyCoeff);
    vec3 saturated = mix(vec3(intensity), brightened, saturation);
    vec3 contrasted = mix(meanLuminosity, saturated, contrast);
    
    return contrasted;
}

vec3 vegnetteColor(vec3 color, vec2 coord, float vig_x, float vig_y)
{
    float dist = distance(coord, vec2(0.5, 0.5));
    return vec3(smoothstep(vig_x, vig_y, dist));
}

void main()
{
    vec3 color;
    float vertMovementOn = 0.0;
    float vertJerk = 0.0;
    float vertJerk2 = 0.0;
    float yOffset = 0.0;
    float xOffset = 0.0;
    float fuzzOffset = 0.0;
    float largeFuzzOffset = 0.0;
    float staticVal = 0.0;

    vec2 texCoord = radialDistortion(v_tex_coord, u_distortion);
    
    // If the texture coordinate is outside of the texture coordinates then discard the texel
    if (texCoord.x < 0 || texCoord.y < 0 || texCoord.x > 1 || texCoord.y > 1)
    {
        color = vec3(0.1, 0.1, 0.1);
    }
    else
    {
//        if (u_vert_roll > 0.0)
//        {
//            vertMovementOn = (1.0 - step(snoise(vec2(u_time * 0.2, 8.0)), 0.4)) * u_vert_roll;
//        }
        
        if (u_vert_jump > 0.0)
        {
            vertJerk = (1.0 - step(snoise(vec2(u_time * 1.5, 5.0)), 0.6)) * u_vert_jump;
            vertJerk2 = (1.0 - step(snoise(vec2(u_time * 5.5, 5.0)), 0.2)) * u_vert_jump;
        }
        
        if (u_horiz_offset > 0.0)
        {
            fuzzOffset = snoise(vec2(u_time * 15.0, texCoord.y * 80.0)) * 0.003;
            largeFuzzOffset = snoise(vec2(u_time * 1.0, texCoord.y * 25.0)) * 0.004;
        }

//        if (u_vert_roll > 0.0 || u_vert_jump > 0.0)
//        {
//            yOffset = abs(sin(u_time) * 4.0) * vertMovementOn + vertJerk * vertJerk2 * 0.3;
//        }

        float y = mod(texCoord.y + yOffset, 1.0);
        
        xOffset = (fuzzOffset + largeFuzzOffset) * u_horiz_offset;
        
//        if (u_static > 0.0)
//        {
//            for (float y = -1.0; y <= 1.0; y += 1.0) {
//                float maxDist = 5.0 / 200.0;
//                float dist = y / 200.0;
//                staticVal += staticV(vec2(texCoord.x, texCoord.y + dist), u_time) * (maxDist-abs(dist)) * 1.5;
//            }
//            staticVal *= u_static;
//        }

        float red 	=   texture2D(	u_texture, 	vec2(texCoord.x + xOffset - 0.01 * u_rgb_offset, y)).r + staticVal;
        float green = 	texture2D(	u_texture, 	vec2(texCoord.x + xOffset, y)).g + staticVal;
        float blue 	=	texture2D(	u_texture, 	vec2(texCoord.x + xOffset + 0.01 * u_rgb_offset, y)).b + staticVal;
        
        color = vec3(red,green,blue);

        color = colorCorrection(color, u_saturation, u_contrast, u_brightness);

        float scanline = sin(texCoord.y * 880) * 0.04 * u_scan_line;
        color -= scanline;

        vec3 vignette = vegnetteColor(color, texCoord, u_vignette_x, u_vignette_y);
    
        if (u_show_vignette == 1.0)
        {
            color *= vignette;
        }
        
        if (u_show_reflection == 1.0)
        {
            vec4 reflection_color = texture2D(u_reflection, texCoord);
            color = mix(vec3(reflection_color) ,color , 0.75);
        }
    }
    
    gl_FragColor = vec4(color, 1.0);
}

