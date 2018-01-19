from paraview.simple import *

files = ['my_vtk_file%d.vtu' % (i+1) for i in range(0,2000)]
reader = OpenDataFile(files)

print reader.PointArrayStatus
print reader.CellArrayStatus

reader.UpdatePipeline()

glyph1 = Glyph(Input=reader, GlyphType="Sphere", Scalars='Mass', ScaleMode='scalar')
glyph2 = Glyph(Input=reader, GlyphType="Sphere", Scalars='Pointmass', ScaleMode='scalar')
glyph3 = Glyph(Input=reader, GlyphType="Arrow", Vectors='Velocity', ScaleMode='vector')
glyph4 = Glyph(Input=reader, GlyphType="Arrow", Vectors='pointvelocity', ScaleMode='vector')
