mutable struct Point
	position::Array{Float64,1}
	velocity::Array{Float64,1}
	acceleration::Array{Float64,1}
    mass::Float64
end

function acceleration_update(points::Array{Point,1}, N)
	for i = 1:N
		points[i].acceleration = [0., 0.]
		for j = 1:N
			if i == j
				continue
			end
			r = points[i].position - points[j].position
			points[i].acceleration += - GravitationalConstant * points[1].mass * points[2].mass / norm(r)^3 * r
		end
	end
end

function velocity_update(points::Array{Point,1}, N)
	for i = 1:N
		points[i].velocity += points[i].acceleration * dt / points[i].mass #(accelration+old_acc)/2
	end
end

function position_update(points::Array{Point,1}, N)
	for i = 1:N
		points[i].position += points[i].velocity * dt  #+ acceleration*dt*dt/mass
	end
end


using WriteVTK

pointAmount = 20

GravitationalConstant = 6.673e-8
points = [Point([rand();rand()],[0.,0.], [0.,0.], rand()) for n in 1:pointAmount]

dt = 1

for i = 1:20
	acceleration_update(points, pointAmount)
	velocity_update(points, pointAmount)
	position_update(points, pointAmount)
	cells = [MeshCell(VTKCellTypes.VTK_EMPTY_CELL, Int[])]
	vtkfile = vtk_grid(string("my_vtk_file",i), reshape([points[i].position[j] for i = 1:20 for j = 1:2], 2, 20), cells)
	vtk_point_data(vtkfile, reshape([points[i].velocity[j] for i = 1:20 for j = 1:2],2,20), "my_point_data")
	outfiles = vtk_save(vtkfile)


end


