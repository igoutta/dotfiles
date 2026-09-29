# Machine-specific config for `tuf` (Arch laptop). Sourced by .zshrc when $HOST matches.

# ArduPilot: ccache delante (waf busca g++ y arm-none-eabi-g++ por PATH), luego el toolchain
path=(/usr/lib/ccache/bin /opt/gcc-arm-none-eabi-10-2020-q4-major/bin $path)
export MAP_SERVICE=GoogleSat

# USB capture card as a low-latency fullscreen stream
alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'
