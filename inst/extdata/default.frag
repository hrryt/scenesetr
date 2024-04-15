#version 330 core
out vec4 FragColor;

in vec2 pos;

uniform vec2 screen_size = vec2(1920,1080);
uniform float time = 0.0;
uniform float spin_time = 0.0;
uniform vec4 colour_1 = vec4(1.0,0.0,0.0,1.0);
uniform vec4 colour_2 = vec4(0.0,0.0,0.0,1.0);
uniform vec4 colour_3 = vec4(0.0,0.0,0.0,1.0);
uniform float contrast = 0.5;
uniform float spin_amount = 0.5;
uniform float PIXEL_SIZE_FAC = 700.0;
uniform float SPIN_EASE = 0.5;

void main()
{
  vec2 screen_coords = gl_FragCoord.xy;

  //Convert to UV coords (0-1) and floor for pixel effect
  float pixel_size = length(screen_size)/PIXEL_SIZE_FAC;
  vec2 uv = (floor(screen_coords.xy*(1./pixel_size))*pixel_size - 0.5*screen_size)/length(screen_size) - vec2(0.12, 0.);
  float uv_len = length(uv);

  //Adding in a center swirl, changes with time. Only applies meaningfully if the 'spin amount' is a non-zero float
  float speed = (spin_time*SPIN_EASE*0.2) + 302.2;
  float new_pixel_angle = (atan(uv.y, uv.x)) + speed - SPIN_EASE*20.*(1.*spin_amount*uv_len + (1. - 1.*spin_amount));
  vec2 mid = (screen_size/length(screen_size))/2.;
  uv = (vec2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid);

  //Now add the paint effect to the swirled UV
  uv *= 30.;
  speed = time*(2.);
  vec2 uv2 = vec2(uv.x+uv.y);

  for(int i=0; i < 5; i++) {
    uv2 += sin(max(uv.x, uv.y)) + uv;
    uv  += 0.5*vec2(cos(5.1123314 + 0.353*uv2.y + speed*0.131121),sin(uv2.x - 0.113*speed));
    uv  -= 1.0*cos(uv.x + uv.y) - 1.0*sin(uv.x*0.711 - uv.y);
  }

  //Make the paint amount range from 0 - 2
  float contrast_mod = (0.25*contrast + 0.5*spin_amount + 1.2);
  float paint_res =min(2., max(0.,length(uv)*(0.035)*contrast_mod));
  float c1p = max(0.,1. - contrast_mod*abs(1.-paint_res));
  float c2p = max(0.,1. - contrast_mod*abs(paint_res));
  float c3p = 1. - min(1., c1p + c2p);

  vec4 ret_col = (0.3/contrast)*colour_1 + (1. - 0.3/contrast)*(colour_1*c1p + colour_2*c2p + vec4(c3p*colour_3.rgb, c3p*colour_1.a));

  FragColor = ret_col;
}