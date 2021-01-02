# Triple Nested Loop
module Genuary01
  WINDOW_WIDTH = 500
  WINDOW_HEIGHT = 400
  SIZE           = 7
  POLYGON_RADIUS = 7
  POLYGON_DISTANCE = 70

  #SIDES_ARRAY  = (3..10).to_a
  DIRECTIONALS = {
    x: {x: 0.3, y: 0.15},
    y: {x: 0.0, y: -0.3},
    z: {x: -0.3, y: 0.15},
  }

  COLORS = %w[red orangered orange yellow green blue purple violet pink magenta]
end

get "/01" do |env|
  env.redirect "/01/0"
end

get "/01/:seed" do |env|
  integer_seed = 0
  begin
    integer_seed = (env.params.url["seed"].to_i % Int32::MAX).to_i32
  rescue
    integer_seed = ((env.params.url["seed"].hash.to_i128 &- Int64::MAX) % Int32::MAX).to_i32
  end
  svg = Celestine.draw do |ctx|
    ctx.width = 100
    ctx.width_units = "%"
    ctx.height = 100
    ctx.height_units = "%"
    ctx.view_box = {x: 0, y: 0, w: Genuary01::WINDOW_WIDTH, h: Genuary01::WINDOW_HEIGHT}

    ctx.path(define: true) do |path|
      path.id = "hexagon"
      path.a_move(0, Genuary01::POLYGON_RADIUS)

      6.times do |x|
        point = Celestine::FPoint.new(0, Genuary01::POLYGON_RADIUS)
        deg_inc = 360.to_f/6
        rp = Celestine::Math.rotate_point(point, Celestine::FPoint::ZERO, deg_inc*x)
        path.a_line(rp.x.floor, rp.y.floor)
      end

      path.opacity = 0.6

      path
    end

    ctx.group do |group|
      Genuary01::SIZE.times do |y|
        Genuary01::SIZE.times do |z|
          Genuary01::SIZE.times do |x|
            group.use("hexagon") do |use|
              px = 0
              py = 0

              px += x * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:x][:x]
              py += x * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:x][:y]

              px += z * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:z][:x]
              py += z * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:z][:y]

              px += y * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:y][:x]
              py += y * Genuary01::POLYGON_DISTANCE * Genuary01::DIRECTIONALS[:y][:y]

              use.x = px
              use.fill = Genuary01::COLORS[y]

              timing_position_loop = {} of Symbol => Int32
              timing_position_loop[:x] = x
              timing_position_loop[:z] = z

              until timing_position_loop[:x] == 0 || timing_position_loop[:z] == 0 
                timing_position_loop[:x] -= 1
                timing_position_loop[:z] -= 1
              end

              timing_position = if timing_position_loop[:z] == 0
                (Genuary01::SIZE + timing_position_loop[:x])/(Genuary01::SIZE*2)
              else # timing_position_loop[:x] == 0
                (Genuary01::SIZE - timing_position_loop[:z])/(Genuary01::SIZE*2)
              end

              use.animate do |anim|
                anim.attribute = "y"
                anim.values << py
                anim.values << py
                anim.values << py + (20 * ((Genuary01::SIZE-y) - (Genuary01::SIZE/2.0).round))
                anim.values << py
                anim.values << py


                anim.key_times << 0
                anim.key_times << (timing_position * 0.5)
                anim.key_times << ((timing_position * 0.5) + 0.25)
                anim.key_times << ((timing_position * 0.5) + 0.45)
                anim.key_times << 1

                anim.custom_attrs["calcMode"] = "spline"

                4.times do
                  anim.key_splines << "0.5 0 0.5 1"
                end
                anim.duration = 2
                anim.duration_units = "s"
                anim.repeat_count = "indefinite"
                anim
              end

              use
            end
          end
        end
      end
      group.transform do |t|
        t.translate(Genuary01::WINDOW_WIDTH/2.0, (Genuary01::WINDOW_HEIGHT/2.0)-25)
        t
      end
      group
    end
  end

  render_layout("view")
end
