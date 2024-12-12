#include "numericalIntegration.h"

int main() {

	const float screenWidth = 800;
	const float screenHeight = 600; 

	InitWindow(screenWidth, screenHeight, "hi");
	SetTargetFPS(60);

	 // Button properties
    Rectangle showSamplesButton = { 
        screenWidth/2 - 100, 
        screenHeight - 100, 
        200, 
        50 
    };
    bool showSamples = false;
    
    // Sample results storage
    char sample1Results[256] = {0};
    char sample2Results[256] = {0};
    
    // Capture stdout to string for displaying on screen
    FILE* outputFile = fmemopen(sample1Results, sizeof(sample1Results), "w");
    FILE* originalStdout = stdout;
    stdout = outputFile;
    runSample1();
    fclose(outputFile);
    stdout = originalStdout;
    
    outputFile = fmemopen(sample2Results, sizeof(sample2Results), "w");
    stdout = outputFile;
    runSample2();
    fclose(outputFile);
    stdout = originalStdout;
    
    while (!WindowShouldClose()) {
        // Check button click
        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
            if (CheckCollisionPointRec(GetMousePosition(), showSamplesButton)) {
                showSamples = !showSamples;
            }
        }
        
        BeginDrawing();
            ClearBackground(RAYWHITE);
            
            // Draw button
            DrawRectangleRec(showSamplesButton, LIGHTGRAY);
            DrawRectangleLinesEx(showSamplesButton, 2, BLACK);
            DrawText("Show Samples", 
                showSamplesButton.x + 30, 
                showSamplesButton.y + 15, 
                20, 
                BLACK
            );
            
            // Draw sample results if button is toggled
            if (showSamples) {
                DrawText("Sample 1 Results:", 50, 100, 20, BLACK);
                DrawText(sample1Results, 50, 130, 20, DARKGRAY);
                
                DrawText("Sample 2 Results:", 50, 250, 20, BLACK);
                DrawText(sample2Results, 50, 280, 20, DARKGRAY);
            }
            
        EndDrawing();
    }
    
    CloseWindow();
    return 0;
}
