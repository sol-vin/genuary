require "celestine"
require "kemal"
require "perlin_noise"

require "./macros/**"

require "./genuary/**"

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run