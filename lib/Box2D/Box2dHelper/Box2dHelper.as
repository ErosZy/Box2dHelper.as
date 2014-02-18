package Box2D.Box2dHelper
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;

	public class Box2dHelper
	{	
		//对外提供的update事件
		public static const EVENT_UPDATE:String = "update";
		
		
		//BOX2D的比例转换
		private static const WORLD_SCALE:Number = 30;
		//官方推荐的触发的timestamp
		private static const TIME_STAMP:Number = 1/30;
		//官方推荐的vel
		private static const VEL:Number = 8;
		//官方推荐的pos
		private static const POS:Number = 3;
		
		private static var world:b2World;
		private static var stage:Sprite;
		private static var interCallback:Vector.<Function> = new Vector.<Function>();
		private static var contactCallback:Vector.<Function> = new Vector.<Function>();
		
		//创建世界
		public static function createWorld(_stage:Sprite):b2World
		{
			world = new b2World(new b2Vec2(0,9.81),true);
			
			stage = _stage;
			
			stage.addEventListener(Event.ENTER_FRAME,updateWorld);
			
			return world;
		}
		
		//绘制调试界面
		public static function debugDraw():void
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			stage.addChild(debugSprite);
			
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetDrawScale(WORLD_SCALE);
			debugDraw.SetSprite(debugSprite);
			
			world.SetDebugDraw(debugDraw);
			
			stage.addEventListener(Event.ENTER_FRAME,drawDebug);
		}
		
		//创建任意多边形
		public static function drawPolygonShape(pos:Point,vertices:Vector.<b2Vec2>,vertex:uint,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			for each(var vertice:b2Vec2 in vertices)
			{
				vertice.x = vertice.x/WORLD_SCALE;
				vertice.y = vertice.y/WORLD_SCALE;
			}
			
			var polygonShapeDef:b2BodyDef = new b2BodyDef();
			polygonShapeDef.position.Set(pos.x/WORLD_SCALE,pos.y/WORLD_SCALE);
			
			var polygonShape:b2PolygonShape = new b2PolygonShape();
			polygonShape.SetAsVector(vertices,vertex);
			
			var fixtureDef:b2FixtureDef = createFixtureDef(polygonShape,density,friction,restitution);
			
			var shapeBody:b2Body = world.CreateBody(polygonShapeDef);
			shapeBody.CreateFixture(fixtureDef);
			
			return shapeBody;
		}
		
		//创建一般图形
		public static function drawShape(pos:Point,hx:Number,hy:Number,center:b2Vec2,angle:Number,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			center = new b2Vec2(center.x/WORLD_SCALE,center.y/WORLD_SCALE);
			
			var shapeDef:b2BodyDef = new b2BodyDef();
			shapeDef.position.Set(pos.x/WORLD_SCALE,pos.y/WORLD_SCALE);
			
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsOrientedBox(hx/WORLD_SCALE,hy/WORLD_SCALE,center,angle);
			
			var fixtureDef:b2FixtureDef = createFixtureDef(shape,density,friction,restitution);
			
			var shapeBody:b2Body = world.CreateBody(shapeDef);
			shapeBody.CreateFixture(fixtureDef);
			
			return shapeBody;
		}
		
		//创建矩形
		public static function drawRect(pos:Point,hx:Number,hy:Number,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.position.Set(pos.x/WORLD_SCALE,pos.y/WORLD_SCALE);
			rectDef.type = type;
			
			var rectShape:b2PolygonShape = new b2PolygonShape();
			rectShape.SetAsBox(hx/WORLD_SCALE,hy/WORLD_SCALE);
			
			var fixtureDef:b2FixtureDef = createFixtureDef(rectShape,density,friction,restitution);
			
			var rectBody:b2Body = world.CreateBody(rectDef);
			rectBody.CreateFixture(fixtureDef);
			
			return rectBody;
		}
		
		//添加圆形
		public static function drawCircle(pos:Point,radius:Number,type:uint=2,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{	
			var circleDef:b2BodyDef = new b2BodyDef();
			circleDef.position.Set(pos.x/WORLD_SCALE,pos.y/WORLD_SCALE);
			circleDef.type = type;
			
			var circleShape:b2CircleShape = new b2CircleShape(radius/WORLD_SCALE);
			
			var fixtureDef:b2FixtureDef = createFixtureDef(circleShape,density,friction,restitution)
			
			var circleBody:b2Body = world.CreateBody(circleDef);
			circleBody.CreateFixture(fixtureDef);
			
			return circleBody;
		}
		
		//创建fixture定义
		public static function createFixtureDef(shape:b2Shape,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2FixtureDef
		{
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			fixtureDef.shape = shape;
			
			return fixtureDef;
		}
		
		//创建鼠标拖拽点
		public static function createMouseJoint(bodyA:b2Body,bodyB:b2Body,target:b2Vec2,maxForce:Number):b2MouseJoint
		{
			target = new b2Vec2(target.x/WORLD_SCALE,target.y/WORLD_SCALE);
			
			var jointDef:b2MouseJointDef = new b2MouseJointDef();
			jointDef.bodyA = bodyA;
			jointDef.bodyB = bodyB;
			jointDef.target = target;
			jointDef.maxForce = maxForce;
			
			return world.CreateJoint(jointDef) as b2MouseJoint;
		}
		
		//创建距离拖拽点
		public static function createDistJoint(bodyA:b2Body,bodyB:b2Body,anchorA:b2Vec2,anchorB:b2Vec2,distance:Number):b2DistanceJoint
		{
			distance = distance / WORLD_SCALE;
			anchorA = new b2Vec2(anchorA.x/WORLD_SCALE,anchorA.y/WORLD_SCALE);
			anchorB = new b2Vec2(anchorB.x/WORLD_SCALE,anchorB.y/WORLD_SCALE);
			
			var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.bodyA = bodyA;
			jointDef.bodyB = bodyB;
			jointDef.localAnchorA = anchorA;
			jointDef.localAnchorB = anchorB;
			jointDef.length = distance;
			
			return world.CreateJoint(jointDef) as b2DistanceJoint;
		}
		
		//创建旋转拖拽点
		public static function createRevoJoint(bodyA:b2Body,bodyB:b2Body,anchorA:b2Vec2,anchorB:b2Vec2,enableMotor:Boolean=false,maxMotorTorque:Number=1000,motorSpeed:Number=0):b2RevoluteJoint
		{
			anchorA = new b2Vec2(anchorA.x/WORLD_SCALE,anchorA.y/WORLD_SCALE);
			anchorB = new b2Vec2(anchorB.x/WORLD_SCALE,anchorB.y/WORLD_SCALE);
			
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = bodyA;
			jointDef.bodyB = bodyB;
			jointDef.localAnchorA = anchorA;
			jointDef.localAnchorB = anchorB;
			jointDef.enableMotor = enableMotor;
			jointDef.maxMotorTorque = maxMotorTorque;
			jointDef.motorSpeed = motorSpeed;
			
			return world.CreateJoint(jointDef) as b2RevoluteJoint;
		}
		
		//与b2Body的交互
		public static function queryPoint(callback:Function,vector:b2Vec2):void
		{
			vector = new b2Vec2(vector.x/WORLD_SCALE,vector.y/WORLD_SCALE);
			
			world.QueryPoint(callback,vector);
		}
		
		//快速遍历bodyList
		public static function bodyInter(callback:Function):void
		{
			interCallback.push(callback);
			stage.addEventListener(Event.ENTER_FRAME,bodyInteration);	
		}
		
		public static function contactInter(callback:Function):void
		{
			contactCallback.push(callback);
			stage.addEventListener(Event.ENTER_FRAME,contactInteration);	
		}
		
		//获取世界对象
		public static function getWorld():b2World
		{
			return world;
		}
		
		//获取timeStamp
		public static function getTimeStamp():Number
		{
			return TIME_STAMP;
		}
		
		//事件绑定函数
		public static function bind(eventName:String,fn:Function):void
		{
			stage.addEventListener(eventName,fn);
		}
		
		//事件触发
		public static function trigger(ev:Event):void
		{
			stage.dispatchEvent(ev);
		}
		
		//绘制调试界面事件处理函数
		private static function drawDebug(event:Event):void
		{	
			world.DrawDebugData();	
		}
		
		//创建世界事件处理函数
		private static function updateWorld(event:Event):void
		{
			world.Step(TIME_STAMP,VEL,POS);
			world.ClearForces();
			
			stage.dispatchEvent(new Event(EVENT_UPDATE));
		}
		
		//遍历bodyList事件处理函数
		private static function bodyInteration(event:Event):void
		{
			for(var b:b2Body = world.GetBodyList();b;b = b.GetNext())
			{
				for each(var fn:Function in interCallback)
					fn(b);
			}
		}
		
		//遍历contactList事件处理函数
		private static function contactInteration(event:Event):void
		{
			for(var c:b2Contact = world.GetContactList();c;c = c.GetNext())
			{
				for each (var fn:Function in contactCallback)
				{
					var fixtureA:b2Fixture = c.GetFixtureA();
					var fixtureB:b2Fixture = c.GetFixtureB();
					fn(fixtureA,fixtureB);
				}
			}
		}
	}
}