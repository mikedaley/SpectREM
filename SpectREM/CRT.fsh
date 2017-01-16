//
//  CRT.fsh
//  SpectREM
//
//  Created by Mike Daley on 17/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//
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
    vec2 texCoord = radialDistortion(v_tex_coord, u_distortion);
    vec3 colorCorrect = colorCorrection(texture2D(u_texture, texCoord).rgb, u_saturation, u_contrast, u_brightness);
    vec3 vignette = vegnetteColor(v_color_mix.rgb, texCoord, u_vignette_x, u_vignette_y);
    vec4 finalColor = (vec4(colorCorrect, 1));
    
    if (u_show_vignette == 1.0)
    {
        finalColor *= vec4(vignette, 1);
    }

    // If the texture coordinate is outside of the texture coordinates then discard the texel
    if (texCoord.x < 0 || texCoord.y < 0 || texCoord.x > 1 || texCoord.y > 1)
    {
        
        finalColor = vec4(0.35, 0.35, 0.35, 1.0);
    }

    gl_FragColor = finalColor;
}

