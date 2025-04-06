@tool
class_name QuadNode
extends Node

var center:Vector2
var center3:Vector3
var lod:int
var root:Terrain
var transform:Transform3D
var scenario:RID
var space:RID
var qnode = load("res://planet/quad_node.gd")
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
	center3 = (Vector3(center.x,1<<root.size-1,center.y)).normalized()*(1<<root.size-1)
	root.moved.connect.call_deferred(update_transform)
	build()

func _process(_delta):
	if not queued:
		if leaf:
			leaf = not checkForSplit()
		else:
			checkForDelete()

func build():
	var s = 32<<lod
	node = generate(int(center.x-s)>>6,int(center.y-s)>>6)

func checkForDelete():
	if Engine.is_editor_hint():return false
	var pos = get_tree().get_first_node_in_group("observer")
	if not pos: return
	d = (pos.global_position-root.global_transform*center3).length()
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
	if Engine.is_editor_hint():return false
	if lod<=root.lod:return false
	var pos = get_tree().get_first_node_in_group("observer")
	if not pos: return
	d = (pos.global_position-root.global_transform*center3).length()
	if d < 64<<lod:
		WorkerThreadPool.add_task(self.split)
		
		queued = true
		return true
	return false

func split():
	var s = 16<<lod
	call_deferred("add_child",qnode.new(center+Vector2(s,s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(-s,s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(s,-s),lod-1,root,transform,scenario,space))
	call_deferred("add_child",qnode.new(center+Vector2(-s,-s),lod-1,root,transform,scenario,space))
	RenderingServer.instance_set_visible(instance,false)
	PhysicsServer3D.body_set_shape_disabled(collider,0,true)
	queued = false
	return true

func _exit_tree():
	if rendered:
		RenderingServer.free_rid(instance)
		PhysicsServer3D.free_rid(shape)
		PhysicsServer3D.free_rid(collider)

func get_vertex(x,z,cx,cz):
	var gx = x+cx
	var gz = z+cz
	var v := Vector3(gx,1<<root.size-1,gz)
	var n = v.normalized()
	v = n*(1<<root.size-1)
	var h = root.generator._get_height(transform * n)
	v += n * h
	v -= center3
	return v

func generate(cx:int,cz:int):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var s = 1<<lod
	cx = cx<<6
	cz = cz<<6
	
	var verts := PackedVector3Array()
	for x in range(65):
		for y in range(65):
			verts.append(get_vertex(x*s,y*s,cx,cz))
	
	for x in range(64):
		for y in range(64):
			var p = verts[x*65+y+1]
			var px = verts[x*65+y]
			var py = verts[x*65+y+66]
			var pxy = verts[x*65+y+65]
			
			st.set_uv(Vector2(x,y)*s)
			st.add_vertex(p)
			st.set_uv(Vector2(x+1,y)*s)
			st.add_vertex(px)
			st.set_uv(Vector2(x,y+1)*s)
			st.add_vertex(py)
			
			st.set_uv(Vector2(x+1,y)*s)
			st.add_vertex(px)
			st.set_uv(Vector2(x+1,y+1)*s)
			st.add_vertex(pxy)
			st.set_uv(Vector2(x,y+1)*s)
			st.add_vertex(py)
	
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()
	material = root.material.duplicate()
	mesh.surface_set_material(0,material)
	instance = RenderingServer.instance_create()
	RenderingServer.instance_set_base(instance, mesh)
	
	shape = PhysicsServer3D.concave_polygon_shape_create()
	
	PhysicsServer3D.shape_set_data(shape,{
		"faces":st.commit_to_arrays()[Mesh.ARRAY_VERTEX]})
	
	collider = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(collider, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_space(collider, space)
	PhysicsServer3D.body_add_shape(collider,shape)
	
	rendered = true
	update_transform()
	
	var xform = transform
	xform.origin += xform.basis * center3
	material.set_shader_parameter("pos",xform)
	RenderingServer.instance_set_scenario(instance, scenario)

func update_transform():
	if not rendered: return
	var xform:Transform3D = root.global_transform
	xform.origin += xform.basis * center3
	RenderingServer.instance_set_transform(instance, xform)
	PhysicsServer3D.body_set_shape_transform(collider,0,xform)
