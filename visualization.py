from paraview.simple import *

files = ['my_vtk_file%d.vtu' % (i+1) for i in range(0,2000)]
reader = OpenDataFile(files)

reader.UpdatePipeline() #Needed for point data to work with the Glyph call

glyph1 = Glyph(Input=reader, GlyphType="Sphere", Scalars='Mass',
        ScaleMode='scalar') # Cell deta does not work, why?
glyph2 = Glyph(Input=reader, GlyphType="Sphere", Scalars='Pointmass', ScaleMode='scalar')
glyph3 = Glyph(Input=reader, GlyphType="Arrow", Vectors='Velocity',
        ScaleMode='vector') # Cell data does not work, why?
glyph4 = Glyph(Input=reader, GlyphType="Arrow", Vectors='Pointvelocity', ScaleMode='vector')
