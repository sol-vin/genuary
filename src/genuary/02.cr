# Description
module Genuary02
  def self.evolve(generations : UInt32, rule : UInt8, start = true)
    rules = {} of UInt8 => Bool
    (0...8).to_a.reverse.each do |rule_key|
      rules[rule_key.to_u8] = (((rule & (1 << rule_key)) >> rule_key) == 1)
    end

    # Jagged array of the array output
    total_generations = [] of Array(Bool)
    total_generations << [start] # Add the first generation

    generations.times do |g|
      last_generation = total_generations[g]
      last_generation_size = (g * 2) + 1
      current_generation_size = ((g + 1) * 2) + 1

      current_generation = [] of Bool
      current_generation_size.to_i32.times do |i|
        left_cell_neighbor_index = i - 2
        center_cell_neighbor_index = i - 1
        right_cell_neighbor_index = i

        left_cell_neighbor = false
        center_cell_neighbor = false
        right_cell_neighbor = false

        if left_cell_neighbor_index >= 0
          left_cell_neighbor = total_generations[g][left_cell_neighbor_index]
        end

        if center_cell_neighbor_index >= 0 && center_cell_neighbor_index < last_generation_size
          center_cell_neighbor = total_generations[g][center_cell_neighbor_index]
        end

        if right_cell_neighbor_index < last_generation_size
          right_cell_neighbor = total_generations[g][right_cell_neighbor_index]
        end

        rule_to_apply = ((left_cell_neighbor ? 1 : 0) << 2)
        rule_to_apply += ((center_cell_neighbor ? 1 : 0) << 1)
        rule_to_apply += ((right_cell_neighbor ? 1 : 0))

        current_generation << rules[rule_to_apply]
      end

      total_generations << current_generation
    end
    total_generations
  end

  GENERATION_SIZE = 20_u32
  RULE           = 30_u8
  ON_COLOR       = "black"
  OFF_COLOR      = "white"

  WINDOW_WIDTH  = 500
  WINDOW_HEIGHT = 500
  Y_OFFSET = 20
end

get "/02" do |env|
  env.redirect "/02/0"
end

# Change this to the day number!
get "/02/:seed" do |env|
  integer_seed = 0
  begin
    integer_seed = (env.params.url["seed"].to_i % Int32::MAX).to_i32
  rescue
    integer_seed = ((env.params.url["seed"].hash.to_i128 &- Int64::MAX) % Int32::MAX).to_i32
  end

  cell_size = Genuary02::WINDOW_WIDTH/((Genuary02::GENERATION_SIZE * 2) + 1)
  ca_data = Genuary02.evolve(Genuary02::GENERATION_SIZE, Genuary02::RULE)

  svg = Celestine.draw do |ctx|
    ctx.height = 100
    ctx.height_units = "%"
    ctx.view_box = {x: 0, y: 0, w: Genuary02::WINDOW_WIDTH, h: Genuary02::WINDOW_HEIGHT}

    Genuary02::GENERATION_SIZE.times do |y|
      ((Genuary02::GENERATION_SIZE * 2) + 1).times do |x|
        offset = Genuary02::GENERATION_SIZE + 1 - y

        if x >= offset && x < offset + (y * 2) + 1
          if ca_data[y][x - offset]
            ctx.rectangle do |r|
              r.x = x * cell_size
              r.y = y * cell_size + Y_OFFSET
              r.width = cell_size
              r.height = cell_size
              r.fill = Genuary02::ON_COLOR
              r.animate_transform_rotate do |a|
                ox = (x * cell_size) + cell_size/2
                oy = (y * cell_size + Y_OFFSET) + cell_size/2

                a.duration = 5
                a.values << "0,#{ox},#{oy}"
                a.values << "45,#{ox},#{oy}"
                a.values << "45,#{ox},#{oy}"
                a.values << "0,#{ox},#{oy}"
                a.values << "0,#{ox},#{oy}"


                a.calc_mode = "spline"

                a.key_splines << "0.5 0 0.5 1"
                a.key_splines << "0.5 0 0.5 1"
                a.key_splines << "0.5 0 0.5 1"
                a.key_splines << "0.5 0 0.5 1"
                a.repeat_count = "indefinite"
                a
              end

              r.animate_motion do |a|
                a.duration = 5
                a.mpath do |p|
                  p.a_move(0, 0)
                  p.r_line(0, 0)
                  p
                end
                a.calc_mode = "spline"

                a.key_splines << "0.5 0 0.5 1"
                a.key_splines << "0.5 0 0.5 1"                
                a.key_splines << "0.5 0 0.5 1"
                a.key_splines << "0.5 0 0.5 1"
                a.repeat_count = "indefinite"

                a
              end
              r
            end
          end
        end
      end
    end
  end

  render_layout("view")
end
