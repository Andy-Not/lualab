Will need SDL2, image, mixer, net, and ttf installed prior to insalling lua-sdl2

SDL2_image_DIR=$(brew --prefix sdl2_image) SDL2_image_INCDIR=$(brew --prefix sdl2_image)/include \
SDL2_mixer_DIR=$(brew --prefix sdl2_mixer) SDL2_mixer_INCDIR=$(brew --prefix sdl2_mixer)/include \
SDL2_net_DIR=$(brew --prefix sdl2_net) SDL2_net_INCDIR=$(brew --prefix sdl2_net)/include \
SDL2_ttf_DIR=$(brew --prefix sdl2_ttf) SDL2_ttf_INCDIR=$(brew --prefix sdl2_ttf)/include \
luarocks install lua-sdl2