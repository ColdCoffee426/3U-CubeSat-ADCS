//save this file as a .pde to run in processing
import processing.net.*;

Client myClient;
String sensorData = "";
float ax, ay, az, gx, gy, gz;

// History buffers to store past values for graphing
final int historyLength = 200;
float[] historyAx = new float[historyLength];
float[] historyAy = new float[historyLength];
float[] historyAz = new float[historyLength];
float[] historyGx = new float[historyLength];
float[] historyGy = new float[historyLength];
float[] historyGz = new float[historyLength];
int historyIndex = 0;

void setup() {
  size(1300, 800);
  textSize(14);
  
  // Connect to sensor using ip
  myClient = new Client(this, "192.168.219.166", 5000);
  
  // Initialize history arrays to zero
  for (int i = 0; i < historyLength; i++) {
    historyAx[i] = 0;
    historyAy[i] = 0;
    historyAz[i] = 0;
    historyGx[i] = 0;
    historyGy[i] = 0;
    historyGz[i] = 0;
  }
}

void draw() {
  background(240);
  
  // --- Numeric Display Area ---
  fill(0);
  // Accel values (in g)
  text("Accelerometer (g):", 20, 30);
  text("ax = " + nf(ax, 1, 4) + " g", 20, 50);
  text("ay = " + nf(ay, 1, 4) + " g", 20, 70);
  text("az = " + nf(az, 1, 4) + " g", 20, 90);
  
  // Gyro values (in °/s)
  text("Gyroscope (°/s):", 700, 30);
  text("gx = " + nf(gx, 1, 4) + " °/s", 700, 50);
  text("gy = " + nf(gy, 1, 4) + " °/s", 700, 70);
  text("gz = " + nf(gz, 1, 4) + " °/s", 700, 90);
  
  // Graphing Area
  // margin and label spacing
  int outerMargin = 40;
  int labelWidth = 80;  // Space reserved for tick labels
  
  // Top row for accel graph with fixed range: -0.5 to 0.5
  int topGraphY = 120;  
  int topGraphHeight = 250;
  int subplotWidth = (width - 4 * outerMargin) / 3;
  
  // Aceelerometer subplots in blue color
  drawGraph(historyAx, outerMargin, topGraphY, subplotWidth, topGraphHeight, "ax (g)", color(0, 0, 255), labelWidth, -0.5, 0.5);
  drawGraph(historyAy, 2 * outerMargin + subplotWidth, topGraphY, subplotWidth, topGraphHeight, "ay (g)", color(0, 0, 255), labelWidth, -0.5, 0.5);
  drawGraph(historyAz, 3 * outerMargin + 2 * subplotWidth, topGraphY, subplotWidth, topGraphHeight, "az (g)", color(0, 0, 255), labelWidth, -0.5, 0.5);
  
  // Bottom row for gyro graphs with fixed range: -25 to 25
  int bottomGraphY = topGraphY + topGraphHeight + 80;
  int bottomGraphHeight = 250;
  
  // gyroscope subplots in red
  drawGraph(historyGx, outerMargin, bottomGraphY, subplotWidth, bottomGraphHeight, "gx (°/s)", color(255, 0, 0), labelWidth, -25, 25);
  drawGraph(historyGy, 2 * outerMargin + subplotWidth, bottomGraphY, subplotWidth, bottomGraphHeight, "gy (°/s)", color(255, 0, 0), labelWidth, -25, 25);
  drawGraph(historyGz, 3 * outerMargin + 2 * subplotWidth, bottomGraphY, subplotWidth, bottomGraphHeight, "gz (°/s)", color(255, 0, 0), labelWidth, -25, 25);
}

// Fixed Box for Graphs
// The graph is clipped to its inner area so the line does not exceed the box.
void drawGraph(float[] history, int x, int y, int w, int h, String title, int graphColor, int labelWidth, float fixedMin, float fixedMax) {
  // OUter box for suplots
  stroke(0);
  noFill();
  rect(x, y, w, h);
  
  // Inner Graph Box
  rect(x + labelWidth, y, w - labelWidth, h);
  
  // Title above graphs
  fill(0);
  text(title, x + labelWidth + 5, y + 15);
  
  // Fixed Y-axis range for the graph
  float minVal = fixedMin;
  float maxVal = fixedMax;
  
  int numTicks = 5;
  stroke(150);
  for (int i = 0; i <= numTicks; i++) {
    float tickY = map(i, 0, numTicks, y + h, y);
    // Draw a tick mark at the right edge of the label area
    line(x + labelWidth - 5, tickY, x + labelWidth, tickY);
    float tickVal = lerp(minVal, maxVal, i / float(numTicks));
    fill(0);
    text(nf(tickVal, 1, 2), x + 5, tickY + 5);
  }
  
  stroke(150);
  line(x + labelWidth, y + h, x + labelWidth, y + h + 5);
  line(x + w, y + h, x + w, y + h + 5);
  fill(0);
  text("0", x + labelWidth, y + h + 20);
  text("t", x + w - 20, y + h + 20);
  
  // clipping drawing within the box
  clip(x + labelWidth, y, w - labelWidth, h);
  
  //history data line 
  stroke(graphColor);
  noFill();
  beginShape();
  for (int i = 0; i < history.length; i++) {
    float plotX = map(i, 0, history.length - 1, x + labelWidth, x + w);
    float plotY = map(history[i], minVal, maxVal, y + h, y);
    vertex(plotX, plotY);
  }
  endShape();
  
  // Disable clipping so that other drawings are not affected
  noClip();
}

void clientEvent(Client c) {
  sensorData = c.readStringUntil('\n');
  if (sensorData != null) {
    sensorData = trim(sensorData);
    // Expected format: "ax,ay,az,gx,gy,gz"
    String[] values = split(sensorData, ',');
    if (values.length == 6) {
      ax = float(values[0]);
      ay = float(values[1]);
      az = float(values[2]);
      gx = float(values[3]);
      gy = float(values[4]);
      gz = float(values[5]);
      
      // Update history buffers in a circular fashion
      historyAx[historyIndex] = ax;
      historyAy[historyIndex] = ay;
      historyAz[historyIndex] = az;
      historyGx[historyIndex] = gx;
      historyGy[historyIndex] = gy;
      historyGz[historyIndex] = gz;
      
      historyIndex = (historyIndex + 1) % historyLength;
    }
  }
}
