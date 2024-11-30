#ifndef NUMERICAL_INTEGRATION_H
#define NUMERICAL_INTEGRATION_H

#include <math.h>

double compositeTrapezoidRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals);
double compositeMidpointRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals);
double squareFunction(double x);
double sineFunction(double x);

#endif // NUMERICAL_INTEGRATION_H


