#include <stdio.h>
#include "../hdr/numericalIntegration.h"

int main() {
    // Example 1: Integral of x^2 from 0 to 1
    double lowerLimit1 = 0;
    double upperLimit1 = 1;
    int subintervals1 = 10;

    double resultTrapezoid1 = compositeTrapezoidRule(squareFunction, lowerLimit1, upperLimit1, subintervals1);
    double resultMidpoint1 = compositeMidpointRule(squareFunction, lowerLimit1, upperLimit1, subintervals1);

    printf("Example 1 (x^2 from 0 to 1):\n");
    printf("Composite Trapezoidal Rule: %f\n", resultTrapezoid1);
    printf("Composite Midpoint Rule: %f\n\n", resultMidpoint1);

    // Example 2: Integral of sin(x) from 0 to pi
    double lowerLimit2 = 0;
    double upperLimit2 = M_PI;
    int subintervals2 = 20;

    double resultTrapezoid2 = compositeTrapezoidRule(sineFunction, lowerLimit2, upperLimit2, subintervals2);
    double resultMidpoint2 = compositeMidpointRule(sineFunction, lowerLimit2, upperLimit2, subintervals2);

    printf("Example 2 (sin(x) from 0 to pi):\n");
    printf("Composite Trapezoidal Rule: %f\n", resultTrapezoid2);
    printf("Composite Midpoint Rule: %f\n", resultMidpoint2);

    return 0;
}
