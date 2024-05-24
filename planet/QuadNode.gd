extends Node

class_name QuadNode

var center:Vector2
var center3:Vector3
var lod:int
var root:Node3D
var transform:Transform3D
var scenario:RID
var space:RID
var qnode = load("res://planet/QuadNode.gd")
var rendered = false
var queued = false
var node
var mesh
var instance
var material:ShaderMaterial
var collider
var shape:RID
var leaf = true
var d


func _init(c,l,r,t,s,p):
	center = c
	lod=l
	root=r
	transform=t
	scenario=s
	space=p
	center3 = transform * (Vector3(center.x,1<<root.size-1,center.y)).normalized()*(1<<root.size-1)
	build()

func _ready():
	pass
	#init()

func _process(_delta):
	if not queued:
		if leaf:
			leaf = not checkForSplit()
		else:
			checkForDelete()

func init():
	build()

func build():
	var s = 32<<lod
	node = generate(int(center.x-s)>>6,int(center.y-s)>>6,lod)
	rendered = true

func checkForDelete():
	if Engine.is_editor_hint():return false
	var pos = root.observer.position-root.global_position
	d = (pos-center3).length()
	if d > 96<<lod:
		for i in get_children():
			if not i.leaf:
				return
		for i in get_children():
			i.queue_free()
		leaf = true
		
		RenderingServer.instance_set_visible(instance,true)
		PhysicsServer3D.body_set_shape_disabled(collider,0,false)


func checkForSplit():
	if Engine.is_editor_hint():
		if lod > 4+root.lod+root.size-10:
			split()
			return true
		else:
			return false
	if lod<=root.lod:return false
	var pos = root.observer.position-root.global_position
	d = (pos-center3).length()
	if d < 64<<lod:
#		split()
#		return true
		WorkerThreadPool.add_task(self.split)
#		root.mutex.lock()
#		root.queue.append(self)
#		root.mutex.unlock()
		queued = true
		return true
	return false

func split():
	#print("split "+str(lod))
	var s = 16<<lod
	call_deferred("add_child",qnode.new(center+Vector2(s,s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(-s,s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(s,-s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(-s,-s),lod-1,root,transform,scenario,space))
	RenderingServer.instance_set_visible(instance,false)
	PhysicsServer3D.body_set_shape_disabled(collider,0,true)
	queued = false
	OS.delay_msec(5)
	return true

func _exit_tree():
	if rendered:
		RenderingServer.free_rid(instance)
		PhysicsServer3D.free_rid(shape)
		PhysicsServer3D.free_rid(collider)

func get_height(v:Vector3,sample:bool):
	#return noise.get_noise_3dv(v)*height
	var heightmap = root.heightmap
	var lat = acos(v.y)
	var long = acos(v.x/max(Vector2(v.x,v.z).length(),0.01))
	long *= -sign(v.z)
	var x = (long/(PI)+1)*heightmap.get_height()
	var y = (lat/(PI*2))*heightmap.get_width()
	var h:float
	if sample:
		h = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y)%heightmap.get_height()).r
		var hx = heightmap.get_pixel(int(x+1)%heightmap.get_width(),int(y)%heightmap.get_height()).r
		var hy = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y+1)%heightmap.get_height()).r
		var hxy = heightmap.get_pixel(int(x+1)%heightmap.get_width(),int(y+1)%heightmap.get_height()).r
		var h0 = lerp(h,hx,fmod(x,1))
		var h1 = lerp(hy,hxy,fmod(x,1))
		h = lerp(h0,h1,fmod(y,1))
	else:
		h = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y)%heightmap.get_height()).r
	return h*root.height

func get_vertex(x,z,cx,cz):
	var gx = x+cx
	var gz = z+cz
	var v := Vector3(gx,1<<root.size-1,gz+0.1)
	var n = v.normalized()
	v = n*(1<<root.size-1)
	var h = get_height(transform * (n),true)
	v += n * h
	v -= Vector3(cx,0,cz)
	return v

func generate(cx:int,cz:int,lod):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var s = 1<<lod
	cx = cx<<6
	cz = cz<<6
	
	var tris = []
	
	for x in range(64):
		for y in range(64):
			var p = get_vertex(x*s,y*s,cx,cz)
			var px = get_vertex((x+1)*s,y*s,cx,cz)
			var py = get_vertex(x*s,(y+1)*s,cx,cz)
			var pxy = get_vertex((x+1)*s,(y+1)*s,cx,cz)
			st.add_vertex(p)
			st.add_vertex(px)
			st.add_vertex(py)
			
			st.add_vertex(px)
			st.add_vertex(pxy)
			st.add_vertex(py)
			
			tris.append(p)
			tris.append(px)
			tris.append(py)
			
			tris.append(px)
			tris.append(pxy)
			tris.append(py)
			
	st.generate_normals()
	mesh = st.commit()
	material = root.material.duplicate()
	mesh.surface_set_material(0,material)
	instance = RenderingServer.instance_create()
	RenderingServer.instance_set_base(instance, mesh)
	var xform:Transform3D = root.global_transform
	xform.origin += xform.basis * (Vector3(cx,0,cz))
	RenderingServer.instance_set_transform(instance, xform)
	
	
	shape = PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape,{
		"faces":PackedVector3Array(tris)})
	
	collider = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(collider, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_space(collider, space)
	PhysicsServer3D.body_add_shape(collider,shape,xform)
	
	xform = transform
	xform.origin += xform.basis * (Vector3(cx,0,cz))
	material.set_shader_parameter("pos",xform)
	RenderingServer.instance_set_scenario(instance, scenario)
