#ifndef RENDERER_ENGINE
#define RENDERER_ENGINE

// #define GLFW_DLL

#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <vector>
#include <string>
#include <fstream>

#include "Camera.h"
#include "Rcpp.h"

class GLRenderer {
public:
	// Call glfw and glad. Create window.
	GLRenderer(const char* window_name, int width, int height);

	// Initialise ShaderProgram, taking path to vertex and fragment source file.
	void InitShaderProgram(const char* vertex_shader, const char* fragment_shader);

	// Initialise VAO, VBO and EBO using list of vertices and indices.
	void InitBuffers(std::vector<float>& vertices, std::vector<GLuint>& indices);

	// Clear back buffer.
	// Use at start of main loop before any render calls.
	void Clear();

	// Render currently stored data in VAO/VBO/EBO.
	void Render(int FOVdeg);

	// Swap back and front buffers and poll for events.
	void Update();

	// Returns the chars of keys pressed last frame.
	std::vector<int> GetInputs();

	// Stop the program for an interval to maintain a given number of frames per second.
	void FramerateLimit(int framerate);

	// Clear all buffers and destroy window.
	void Delete();
	
	void SetCameraOrientation(float x, float y, float z);
	void SetCameraPosition(float x, float y, float z);
	void SetCameraUp(float x, float y, float z);
	void SetCameraResolution(float width, float height);
	
	void saveImage(const char* filepath, int width, int height);

	GLFWwindow* window;	// Pointer to stored window.
	GLuint shaderProgram;
	GLuint VBO, VAO, EBO;
	
	Camera camera = Camera(1280, 720, glm::vec3(0.0f, 0.0f, 0.0f));
	
private:
	// Gets the contents of a file at given path.
	std::string GetFileContents(const char* filename);

	double prevTime;
	
	int num_indices;
};

#endif