class TetrisData

  BLOCK_NONE = 0
  BLOCK_FIXED = 1
  BLOCK_UNFIXED = 2

  attr_reader :image_table

  def initialize(x, y)

    raise "Don't set the size of the field as 0." if x <= 0 or y <=0
    init_image_table x, y

  end

  def init_image_table(x, y)
    @y_size = y

    @image_table = Array.new(x + 2).map! do
      Array.new(y + 1, 0)
    end

    @image_table.each_with_index do |ex, ix|
      ex.each_index do |iy|
        if ix == 0 or ix == x + 1 or iy == y
          @image_table[ix][iy] = BLOCK_FIXED
        end
      end
    end

  end

  def set_block_status(block, status)
    center_x = block.x + 1
    center_y = block.y

    @image_table[center_x][center_y] = status
    
    if !block.sp.nil?
      calc_rotate_sp(block.sp, block.current_r).each do |v|
        @image_table[center_x + v[0]][center_y + v[1]] = status
      end
    end
  end

  def set_block(block)
    set_block_status block, BLOCK_UNFIXED
  end
  
  def remove_block(block)
    set_block_status block, BLOCK_NONE
  end

  def right_block(block)

    remove_block block
    if boundary_right? block
      block.move_right
    end
    set_block block

  end

  def boundary?(xy, sp, rotate_count)
    
    points = Array.new
    if !sp.nil?
      calc_rotate_sp(sp, rotate_count).each do |v|
        points << [xy[0] + v[0] + 1, xy[1] + v[1]]
      end
    end
    points << [xy[0] + 1, xy[1]]

    points.each do |v|
      if @image_table[v[0]][v[1]] != BLOCK_NONE
        return false
      end
    end

    return true
  end

  def rotate_block(block)
    remove_block block
    if boundary_rotate? block
      block.rotate
    end
    set_block block
  end

  def boundary_rotate?(block)

    boundary?(
      [block.x, block.y],
      block.sp, block.get_rotated_count
    )

  end

  def calc_rotate_sp(sp, rotate_count)

    return sp if rotate_count == 0

    new_sp = Array.new
    sp.each_index do |idx|
      new_sp << [sp[idx][1] * -1, sp[idx][0]]
    end

    return calc_rotate_sp(new_sp, rotate_count - 1)

  end

  def boundary_right?(block)

    boundary?(block.get_moved_right_points, block.sp, block.current_r)

  end

  def left_block(block)

    remove_block block
    if boundary_left? block
      block.move_left
    end
    set_block block

  end

  def boundary_left?(block)

    boundary?(block.get_moved_left_points, block.sp, block.current_r)

  end
  
  def down_block(block)

    ret_flg = true
    remove_block block
    if boundary_down? block
      block.move_down
    else
      ret_flg = false
    end
    set_block block

    return ret_flg
  end

  def boundary_down?(block)

    boundary?(block.get_moved_down_points, block.sp, block.current_r)

  end
  
  def up_block(block)

    remove_block block
    if boundary_up? block
      block.move_up
    end
    set_block block

  end

  def boundary_up?(block)

    boundary?(block.get_moved_up_points, block.sp, block.current_r)

  end

  def vanish_line(line)
    
    if vanish? line
      set_none_line line
      true
    else
      false
    end

  end

  def vanish?(line)
    proc_line do |ex|
      return false if ex[line] == BLOCK_NONE
    end

    true
  end

  def set_none_line(line)
    proc_line do |ex|
      ex[line] = BLOCK_NONE
    end
  end

  def proc_line
    @image_table.each_with_index do |ex, ix|
      next if ix == 0 or ix == @image_table.size - 1
      yield ex
    end
  end

  def down_line(line)
    line.downto(0) do |iy|
      proc_line do |ex|
        if iy == 0
          ex[iy] = BLOCK_NONE
        else
          ex[iy] = ex[iy - 1]
        end
      end
    end
  end
  
  def vanish_down_proc(start_line = (@y_size - 1))
    start_line.downto(0) do |iy|
      if vanish_line(iy)
        down_line(iy)
        vanish_down_proc iy
      end
    end
  end
end

