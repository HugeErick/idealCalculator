#include "numericalIntegration.h"

double compositeTrapezoidRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals) {
    double stepSize = (upperLimit - lowerLimit) / subintervals;
    double sum = 0.5 * (integrand(lowerLimit) + integrand(upperLimit));
    int i;
    
    for (i = 1; i < subintervals; i++) {
        double x = lowerLimit + i * stepSize;
        sum += integrand(x);
    }
    
    return stepSize * sum;
}

double compositeMidpointRule(double (*integrand)(double), double lowerLimit, double upperLimit, int subintervals) {
    double stepSize = (upperLimit - lowerLimit) / subintervals;
    double sum = 0;
    int i;
    
    for (i = 0; i < subintervals; i++) {
        double xMid = lowerLimit + (i + 0.5) * stepSize;
        sum += integrand(xMid);
    }
    
    return stepSize * sum;
}

double squareFunction(double x) {
    return x * x;  // Example: integral of x^2
}

double sineFunction(double x) {
    return sin(x);
}
