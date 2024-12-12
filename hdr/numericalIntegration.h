#ifndef NUMERICAL_INTEGRATION_H
#define NUMERICAL_INTEGRATION_H

#define M_PI 3.14159

#include <math.h>
#include <stdio.h>
#include "raylib.h"
#include <string.h>

double compositeTrapezoidRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals);
double compositeMidpointRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals);
double squareFunction(double x);
double sineFunction(double x);

void runSample1();
void runSample2();

#endif // NUMERICAL_INTEGRATION_H


