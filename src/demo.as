package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
	
	public class demo extends Sprite
	{
		private const WORLD_SCALE:Number = 30;

		private var world:b2World;
		
		public function demo()
		{
			super();
			//创建世界
			createWorld();
			debugDraw();
			
			var circle:b2Body = drawCircle(new Point(stage.stageWidth-100>>1,0),50,b2Body.b2_dynamicBody);
			drawRect(new Point(0,200),stage.stageWidth,10);
			drawShape(new Point(200,200),5,20,new b2Vec2(0,10),-Math.PI/4);
			var v:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			v.push(new b2Vec2(0,0));
			v.push(new b2Vec2(100,100));
			v.push(new b2Vec2(200,200));
			v.push(new b2Vec2(0,100));
			drawPolygonShape(new Point(150,150),v,4);
			
			addEventListener(MouseEvent.CLICK,clickFn);
			addEventListener(Event.ENTER_FRAME,updateWorld);
		}
		
		protected function clickFn(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var point:b2Vec2 = new b2Vec2(mouseX/WORLD_SCALE,mouseY/WORLD_SCALE);
			world.QueryPoint(destoryHandler,point);
		}
		
		private function destoryHandler(fixture:b2Fixture):Boolean
		{
			// TODO Auto Generated method stub
			var body:b2Body = fixture.GetBody();
			world.DestroyBody(body);
			return false;
		}
		
		//创建任意多边形
		private function drawPolygonShape(pos:Point,vertices:Vector.<b2Vec2>,vertex:uint,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			// TODO Auto Generated method stub
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
		
		//创建世界
		private function createWorld():b2World
		{
			world = new b2World(new b2Vec2(0,9.81),true);
			addEventListener(Event.ENTER_FRAME,updateWorld);
			
			return world;
		}
		
		//调试界面
		private function debugDraw():void
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetDrawScale(WORLD_SCALE);
			debugDraw.SetSprite(debugSprite);
			
			world.SetDebugDraw(debugDraw);
			
			addEventListener(Event.ENTER_FRAME,drawDebug);
		}
		
		//创建一般图形
		private function drawShape(pos:Point,hx:Number,hy:Number,center:b2Vec2,angle:Number,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			// TODO Auto Generated method stub
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
		private function drawRect(pos:Point,hx:Number,hy:Number,type:uint=0,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			// TODO Auto Generated method stub
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
		private function drawCircle(pos:Point,radius:Number,type:uint=2,userData:*=null,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2Body
		{
			// TODO Auto Generated method stub
			
			var circleDef:b2BodyDef = new b2BodyDef();
			circleDef.position.Set(pos.x/WORLD_SCALE,pos.y/WORLD_SCALE);
			circleDef.type = type;
			
			var circleShape:b2CircleShape = new b2CircleShape(radius/WORLD_SCALE);
			
			var fixtureDef:b2FixtureDef = createFixtureDef(circleShape,density,friction,restitution)
			
			var circleBody:b2Body = world.CreateBody(circleDef);
			circleBody.CreateFixture(fixtureDef);
			
			return circleBody;
		}
		
		private function createFixtureDef(shape:b2Shape,density:Number=1,friction:Number=0.4,restitution:Number=0.5):b2FixtureDef
		{
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.friction = friction;
			fixtureDef.restitution = restitution;
			fixtureDef.shape = shape;
			
			return fixtureDef;
		}
		
		//debugDraw的回调
		protected function drawDebug(event:Event):void
		{
			// TODO Auto-generated method stub
			world.DrawDebugData();
		}
		
		//ENTER_FRAME回调
		protected function updateWorld(event:Event):void
		{
			// TODO Auto-generated method stub
			world.Step(1/30,8,3);
			world.ClearForces();
		}
		
	}
}