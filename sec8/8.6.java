// 8.6 Java 言語 (並列部分)

// fig 8.26 有界バッファ(Java)
class Point {
    double x, y;
    Point(double x1, y1) { x=x1; y=y1; }
    public double getX() { return x; }
    public double getY() { return y; }
    public synchronized void origin() { x=0.0; y=0.0; }
    public synchronized void add(Point p)
      { x+=p.getX(); y+=p.getY(); }
    public synchronized void scale(double s) { x*=s; y*=s; }
    public void draw(Graphics g) {
        double lx, ly;
        synchronized (this) { lx=x; ly=y; }
        g.drawPoint(lx, ly);
    }
}

class Buffer {
   int[] buf;
   int first, last, n, i;

   public void init(int size) {
       buf=new int[size];
       n=size; i=0; first=0; last=0;
   }

   public synchronized void put(int x) {
      while (i<n) wait();
      buf[last]=x;
      last=(last+1)%n;
      i=i+1;
      notifyAll();
   }

   public synchronized int get() {
      int x;
      while (i==0) wait();
      x=buf[first];
      first=(first+1)%n;
      i=i-1;
      notifyAll();
      return x;
   }
}

