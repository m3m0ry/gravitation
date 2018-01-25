mutable struct Points
	position::Array{Float64,2}
	velocity::Array{Float64,2}
	acceleration::Array{Float64,2}
	mass::Array{Float64,1}
	size::Int
end

function acceleration_update(points::Points)
	for i = 1:points.size
		points.acceleration[:,i] = [0., 0.]
		for j = 1:points.size
			if i == j
				continue
			end
			r = points.position[:,i] - points.position[:,j]
			if norm(r) < 0.01
				continue
			end
			points.acceleration[:,i] += - GravitationalConstant * points.mass[i] * points.mass[j] / norm(r)^3 * r
		end
	end
end

function velocity_update(points::Points)
	for i = 1:points.size
		points.velocity[:,i] += points.acceleration[:,i] * dt / points.mass[i] #(accelration+old_acc)/2
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
			potential[i,j] = 1/4 * (4*pi*GravitationalConstant*density[i,j] + potential[i-1,j] + potential[i+1,j] + potential[i,j-1] + potential[i,j+1])
		end
	end
end

using WriteVTK

N = 20
grid = 200
dims = 2
GravitationalConstant = 6.673e-8
cells = [MeshCell(VTKCellTypes.VTK_VERTEX, [i]) for i = 1:N]

points = Points(rand(dims,N), zeros(dims,N), zeros(dims,N), rand(N)*100, N)
density = zeros(Float64, grid, grid)
potential = zeros(Float64, grid, grid)

dx = 1/grid
dt = 1

assign_mass(density, points, dx)
for n=1:1000
	gauss_seidel(potential, density)
end


#vtk_write_array("my_vti_file0", potential, "Potential")
outfile = vtk_grid("my_vtr_file0", [i*dx for i=0:grid],[i*dx for i=0:grid]) do vtk
	vtk_cell_data(vtk, density, "Density")
	vtk_cell_data(vtk, potential, "Potential")
end


outfile = vtk_grid(string("my_vtk_file",0), points.position, cells) do vtk
	vtk_cell_data(vtk, points.mass, "Mass")
	vtk_cell_data(vtk, vcat(points.velocity, zeros(1,N)), "Velocity")

	vtk_point_data(vtk, points.mass, "Pointmass")
	vtk_point_data(vtk, vcat(points.velocity, zeros(1,N)), "Pointvelocity")
end



quit()
for i = 1:2000
	acceleration_update(points)
	velocity_update(points)
	position_update(points)
	outfile = vtk_grid(string("my_vtk_file",i), points.position, cells) do vtk
		vtk_cell_data(vtk, points.mass, "Mass")
		vtk_cell_data(vtk, vcat(points.velocity, zeros(1,N)), "Velocity")

		vtk_point_data(vtk, points.mass, "Pointmass")
		vtk_point_data(vtk, vcat(points.velocity, zeros(1,N)), "Pointvelocity")
	end
end


