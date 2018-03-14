mutable struct Points
	position::Array{Float64,2}
	velocity::Array{Float64,2}
	acceleration::Array{Float64,2}
	mass::Array{Float64,1}
	size::Int
end

function acceleration_update(points::Points, force_field::Array{Float64,3})
	for i = 1:points.size
		points.acceleration[:,i] = force_field[:,ceil(Int,points.position[1,i]/dx),ceil(Int,points.position[2,i]/dx)] / points.mass[i]
	end
end

function velocity_update(points::Points)
	for i = 1:points.size
		points.velocity[:,i] += points.acceleration[:,i] * dt #(accelration+old_acc)/2
	end
end

function position_update(points::Points)
	for i = 1:points.size
		points.position[:,i] += points.velocity[:,i] * dt  #+ acceleration*dt*dt/mass
	end
end

function assign_mass(density::Array{Float64,2}, points::Points, dx)
	for i = 1:points.size
		density[ceil(Int, points.position[1,i]/dx),ceil(Int, points.position[2,i]/dx)] = points.mass[i]
	end
end

function gauss_seidel(potential::Array{Float64,2}, density::Array{Float64,2})
	for i = 2:grid-1
		for j = 2:grid-1
			potential[i,j] = -1/4 * (dx^2*4*pi*GravitationalConstant*density[i,j] + (- potential[i-1,j] - potential[i+1,j] - potential[i,j-1] - potential[i,j+1]))
		end
	end
end

function residuum(potentail::Array{Float64,2}, density::Array{Float64,2})
	r = 0.
	for i = 2:grid-1
		for j = 2:grid-1
			r += (4*pi*GravitationalConstant*density[i,j] - (potentail[i+1,j] + potentail[i-1,j] + potentail[i,j+1] + potentail[i,j-1] - 4potentail[i,j]) * 1/dx^2)^2
		end
	end
	return sqrt(r/(grid-2)^2)
end

using WriteVTK

N = 20
grid = 200
ϵ = 0.0001 #residual
ω = 1.8 #SOR
γ = 0.9 #upwind
itermax = 2000
dims = 2
GravitationalConstant = 6.673e-8
cells = WriteVTK.MeshCell[MeshCell(VTKCellTypes.VTK_VERTEX, [i]) for i = 1:N]

points = Points(rand(dims,N), zeros(dims,N), zeros(dims,N), rand(N)*100, N)
density = zeros(Float64, grid, grid)
potential = zeros(Float64, grid, grid)
force_field = zeros(Float64, 2, grid, grid)

dx = 1/grid
dt = 1

for i = 1:60
	outfile = vtk_grid(string("my_vtr_file",i), [i*dx for i=0:grid],[i*dx for i=0:grid]) do vtk
		vtk_cell_data(vtk, density, "Density")
		vtk_cell_data(vtk, potential, "Potential")
		vtk_cell_data(vtk, vcat(force_field, zeros(1,grid,grid)), "Force")
	end

	outfile = vtk_grid(string("my_vtu_file",i), points.position, cells) do vtk
		vtk_cell_data(vtk, points.mass, "Mass")
		vtk_cell_data(vtk, vcat(points.velocity, zeros(1,N)), "Velocity")

		vtk_point_data(vtk, points.mass, "Pointmass")
		vtk_point_data(vtk, vcat(points.velocity, zeros(1,N)), "Pointvelocity")
	end

	density = zeros(Float64, grid, grid)
	assign_mass(density, points, dx)
	for n=1:itermax
		gauss_seidel(potential, density)
		r = residuum(potential, density)
		println(r)
		if r < ϵ
			break
		end
	end

	for i=2:grid-1
		for j=2:grid-1
			force_field[1,i,j] = -(potential[i+1,j] - potential[i-1,j])/dx
			force_field[2,i,j] = -(potential[i,j+1] - potential[i,j-1])/dx
		end
	end

	acceleration_update(points,force_field)
	velocity_update(points)
	position_update(points)
end
