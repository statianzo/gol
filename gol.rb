require 'minitest/autorun'

class World < Struct.new(:grid)
  def neighbors(row, col)
    up = row - 1
    yoopers = up < 0 ? 0 : grid[up][col] + row_neighbors(up, col)
    down = row + 1
    downers = down >= grid.length ? 0 : grid[down][col] + row_neighbors(down, col)
    yoopers + downers + row_neighbors(row, col)
  end

  def next_state(row, col)
    neighbors = neighbors(row, col)
    return grid[row][col] if neighbors == 2
    return 0 if neighbors > 3
    neighbors > 1 ? 1 : 0
  end

  def update
    new_grid = grid.each_with_index.map{|cs,r| cs.each_with_index.map{|_,c| next_state(r, c)}}
    World.new new_grid
  end

  def plot
    grid.each_with_index.map{
      |cs,_| cs.each_with_index.map{|v,_| v}.join(' ')
    }.join("\n")
  end

  private

  def row_neighbors(row, col)
    left = col - 1
    (left < 0 ? 0 : grid[row][left]) + grid[row][col + 1].to_i
  end
end

describe 'game' do
  let(:world) {
    World.new [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]
  }

  it 'has a grid' do
    world.grid.length.must_equal 4
    world.grid.first.length.must_equal 4
  end

  it 'counts zero neighbors' do
    world.neighbors(0,0).must_equal 0
  end

  it 'counts one neighbor' do
    world.grid[0][1] = 1
    world.neighbors(0,0).must_equal 1
  end

  it 'counts eight neighbors' do
    world = World.new [
      [1, 1, 1, 0],
      [1, 1, 1, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
    ]

    world.neighbors(1,1).must_equal 8
  end

  it 'does not count left toroidal neighbors' do
    world.grid[0][-1] = 1
    world.neighbors(0,0).must_equal 0
  end

  it 'does not count up toroidal neighbors' do
    world.grid[-1][0] = 1
    world.neighbors(0,0).must_equal 0
  end

  it 'checks neighbors at bottom' do
    world.neighbors(3,0).must_equal 0
  end

  it 'checks neighbors on the right' do
    world.neighbors(0,3).must_equal 0
  end

  it 'dies with zero neighbors' do
    world.grid[0][0] = 1
    world.next_state(0,0).must_equal 0
  end

  it 'dies with one neighbor' do
    world.grid[0][0] = 1
    world.grid[0][1] = 1
    world.next_state(0,0).must_equal 0
  end

  it 'lives with two neighbors' do
    world.grid[0][0] = 1
    world.grid[0][1] = 1
    world.grid[1][0] = 1
    world.next_state(0,0).must_equal 1
  end

  it 'stays dead with two neighbors' do
    world.grid[0][0] = 0
    world.grid[0][1] = 1
    world.grid[1][0] = 1
    world.next_state(0,0).must_equal 0
  end

  it 'lives with three neighbors' do
    world.grid[0][0] = 1
    world.grid[0][1] = 1
    world.grid[1][0] = 1
    world.grid[1][1] = 1
    world.next_state(0,0).must_equal 1
  end

  it 'is born with three neighbors' do
    world.grid[0][0] = 0
    world.grid[0][1] = 1
    world.grid[1][0] = 1
    world.grid[1][1] = 1
    world.next_state(0,0).must_equal 1
  end

  it 'dies with four neighbors' do
    world = World.new [
      [0, 1, 0, 0],
      [1, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ]
    world.next_state(1,1).must_equal 0
  end

  it 'dies with five neighbors' do
    world = World.new [
      [0, 1, 1, 0],
      [1, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ]
    world.next_state(1,1).must_equal 0
  end

  it 'creates a new world on update' do
    world.update.must_be_instance_of World
  end

  it 'updates grid on update according to live/die rules' do
    world = World.new [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]

    expected = World.new [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ]
    world.update.must_equal expected
  end

  it 'plots a world' do
    world = World.new [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]
    world.plot.must_equal "0 0 0 0\n1 1 1 0\n0 0 0 0\n0 0 0 0"
  end
end

practice = World.new [
  [0, 1, 0, 0],
  [1, 1, 1, 0],
  [0, 1, 0, 0],
  [0, 0, 0, 0],
]

10.times do |i|
  puts "====Generation #{i}===="
  puts practice.plot
  practice = practice.update
  puts
end
