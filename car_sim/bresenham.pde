ArrayList<PVector> bresenham_high(float x0, float y0, float x1, float y1, float d) {
  ArrayList<PVector> result = new ArrayList<PVector>();
  float dx = x1-x0;
  float dy = y1-y0;
  int xi = 1;
  if (dx < 0) {
    xi = -1;
    dx = -dx;
  }
  float D = 2*dx - dy;
  float x = x0;
  for (float y = y0; y < y1; y+=d) {
    result.add(new PVector(x, y));
    if (D > 0) {
      x += xi;
      D -= 2*dy;
    }
    D += 2*dx;
  }
  return result;
}

ArrayList<PVector> bresenham_low(float x0, float y0, float x1, float y1, float d) {
  ArrayList<PVector> result = new ArrayList<PVector>();
  float dx = x1-x0;
  float dy = y1-y0;
  float yi = 1;
  if (dy < 0) {
    yi = -1;
    dy = -dy;
  }
  float D = 2*dy - dx;
  float y = y0;
  for (float x = x0; x < x1; x+=d) {
    result.add(new PVector(x, y));
    if (D > 0) {
      y += yi;
      D -= 2*dx;
    }
    D += 2*dy;
  }
  return result;
}

ArrayList<PVector> bresenham(float x0, float y0, float x1, float y1, float delta) {
  if (abs(y1 - y0) < abs(x1 - x0)) {
    if (x0 > x1) {
      return bresenham_low(x1, y1, x0, y0, delta);
    } else {
      return bresenham_low(x0, y0, x1, y1, delta);
    }
  } else {
    if (y0 > y1) {
      return bresenham_high(x1, y1, x0, y0, delta);
    } else {
      return bresenham_high(x0, y0, x1, y1, delta);
    }
  }
}
