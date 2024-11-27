#include <stdio.h>
#include "../hdr/numericalIntegration.h"

int main() {
    // Integration limits
    double lowerLimit = 0;
    double upperLimit = 1;
    
    // Number of subintervals
    int subintervals = 10;
    
    // Calculate the integral using both methods
    double resultTrapezoid = compositeTrapezoidRule(squareFunction, lowerLimit, upperLimit, subintervals);
    double resultMidpoint = compositeMidpointRule(squareFunction, lowerLimit, upperLimit, subintervals);
    
    // Display results
    printf("Result using the Composite Trapezoidal Rule: %f\n", resultTrapezoid);
    printf("Result using the Composite Midpoint Rule: %f\n", resultMidpoint);
    
    return 0;
}


