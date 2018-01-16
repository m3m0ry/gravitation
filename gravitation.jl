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


using WriteVTK

N = 20
dims = 2
GravitationalConstant = 6.673e-8

points = Points(rand(dims,N), zeros(dims,N), zeros(dims,N), rand(N)*100, N)

dt = 1


for i = 1:200
	acceleration_update(points)
	velocity_update(points)
	position_update(points)
	cells = [MeshCell(VTKCellTypes.VTK_VERTEX, [i]) for i = 1:N]
	vtkfile = vtk_grid(string("my_vtk_file",i), points.position, cells)
	#vtk_point_data(vtkfile, reshape([points[i].velocity[j] for i = 1:20 for j = 1:2],2,20), "Velocity")
	##vtk_point_data(vtkfile, ([points[i].velocity[1] for i = 1:20], [points[i].velocity[2] for i = 1:20]), "Velocity")
	outfiles = vtk_save(vtkfile)
end


