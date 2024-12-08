#ifndef RENDERER_ENGINE
#define RENDERER_ENGINE

// #define GLFW_DLL
#include "Cloud.h"
#include <GLFW/glfw3.h>

class GLRenderer {
public:
	// Call glfw and glad. Create window.
	GLRenderer(const char* window_name, int width, int height);

	// Initialise meshShaderProgram, taking path to vertex and fragment source file.
	void InitMeshShaderProgram(const char* vertex_shader, const char* fragment_shader);
	void InitCloudShaderProgram(const char* vertex_shader, const char* fragment_shader);
	
	void InitMesh(std::vector<float>& vertices, std::vector<GLuint>& indices);
	void InitCloud(std::vector<float>& vertices);
	
	void UpdateMeshBuffer(int i, std::vector<float>& vertices);
	void UpdateCloudBuffer(int i, std::vector<float>& vertices);

	// Clear back buffer.
	// Use at start of main loop before any render calls.
	void Clear();
  
  void UseMeshShaderProgram();
  void UseCloudShaderProgram();
  
	// Render currently stored data in VAO/VBO/EBO.
	void DrawMesh(int i, Rcpp::NumericVector p, Rcpp::NumericVector q);
	void DrawCloud(int i, Rcpp::NumericVector p, Rcpp::NumericVector q);

	// Swap back and front buffers and poll for events.
	void Update();

	// Returns the chars of keys pressed last frame.
	std::vector<int> GetInputs();

	// Stop the program for an interval to maintain a given number of frames per second.
	void FramerateLimit(int framerate);

	// Clear all buffers and destroy window.
	void Delete();
	
	void SetLights(std::vector<float> lightdata);
	void SetCamera(Rcpp::NumericVector p, Rcpp::NumericVector q, float FOVdeg, float aspect);
	void SaveImage(const char* filepath, int width, int height);
	
	bool WindowShouldClose();

	GLFWwindow* window;	// Pointer to stored window.
	GLuint meshShaderProgram, cloudShaderProgram;
	
private:
	// Gets the contents of a file at given path.
	std::string GetFileContents(const char* filename);
	double prevTime;
	int num_indices;
	std::vector<Mesh> meshes;
	std::vector<Cloud> clouds;
};

#endif