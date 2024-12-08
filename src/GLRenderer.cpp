#include "GLRenderer.h"

#include <iostream>
#include <string>
#include <fstream>

// #include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

GLRenderer::GLRenderer(const char* window_name, int width, int height) {
    // Initialize GLFW
    glfwInit();

    // Create a windowed mode window and its OpenGL context
    window = glfwCreateWindow(width, height, window_name, NULL, NULL);
    if (window == NULL)
    {
        glfwTerminate();
        // exit(-1);
    }
    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        glfwTerminate();
        // exit(-1);
    }

    double prevTime = glfwGetTime();
    (void) prevTime;
    
    glEnable(GL_PROGRAM_POINT_SIZE);
    
    glEnable(GL_DEPTH_TEST);
    // glDepthMask(GL_FALSE);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void CompileErrors(unsigned int shader, const char* type) {
  GLint has_compiled;
  char info_log[1024];
  if (strcmp(type, "PROGRAM") != 0) {
    glGetShaderiv(shader, GL_COMPILE_STATUS, &has_compiled);
    if (has_compiled == GL_FALSE) {
      glGetShaderInfoLog(shader, 1024, NULL, info_log);
      Rcpp::Rcout << "SHADER_COMPILATION_ERROR for: " << type << std::endl;
    }
  }
  else {
    glGetProgramiv(shader, GL_COMPILE_STATUS, &has_compiled);
    if (has_compiled == GL_FALSE) {
      glGetProgramInfoLog(shader, 1024, NULL, info_log);
      Rcpp::Rcout << "SHADER_LINKING_ERROR for: " << type << std::endl;
    }
  }
}

void GLRenderer::InitMeshShaderProgram(const char* vertex_shader, const char* fragment_shader) {
  // Set up vertex shader
  std::string vertex_code = GetFileContents(vertex_shader);
  const char* vertex_source = vertex_code.c_str();
  GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertexShader, 1, &vertex_source, NULL);
  glCompileShader(vertexShader);
  CompileErrors(vertexShader, "VERTEX");
  
  // Set up fragment shader
  std::string fragment_code = GetFileContents(fragment_shader);
  const char* fragment_source = fragment_code.c_str();
  GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragmentShader, 1, &fragment_source, NULL);
  glCompileShader(fragmentShader);
  CompileErrors(fragmentShader, "FRAGMENT");
  
  // Link shaders into a program
  meshShaderProgram = glCreateProgram();
  glAttachShader(meshShaderProgram, vertexShader);
  glAttachShader(meshShaderProgram, fragmentShader);
  glLinkProgram(meshShaderProgram);
  
  // Delete shaders (we no longer need them after linking)
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
}

void GLRenderer::InitCloudShaderProgram(const char* vertex_shader, const char* fragment_shader) {
  // Set up vertex shader
  std::string vertex_code = GetFileContents(vertex_shader);
  const char* vertex_source = vertex_code.c_str();
  GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertexShader, 1, &vertex_source, NULL);
  glCompileShader(vertexShader);
  CompileErrors(vertexShader, "VERTEX");
  
  // Set up fragment shader
  std::string fragment_code = GetFileContents(fragment_shader);
  const char* fragment_source = fragment_code.c_str();
  GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragmentShader, 1, &fragment_source, NULL);
  glCompileShader(fragmentShader);
  CompileErrors(fragmentShader, "FRAGMENT");
  
  // Link shaders into a program
  cloudShaderProgram = glCreateProgram();
  glAttachShader(cloudShaderProgram, vertexShader);
  glAttachShader(cloudShaderProgram, fragmentShader);
  glLinkProgram(cloudShaderProgram);
  
  // Delete shaders (we no longer need them after linking)
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
}

void GLRenderer::UseMeshShaderProgram() {
  glUseProgram(meshShaderProgram);
}

void GLRenderer::UseCloudShaderProgram() {
  glUseProgram(cloudShaderProgram);
}

void GLRenderer::InitMesh(std::vector<float>& vertices, std::vector<GLuint>& indices) {
  meshes.push_back(Mesh(vertices, indices));
}

void GLRenderer::InitCloud(std::vector<float>& vertices) {
  clouds.push_back(Cloud(vertices));
}

void GLRenderer::UpdateMeshBuffer(int i, std::vector<float>& vertices) {
  meshes[i].UpdateArrayBuffer(vertices);
}

void GLRenderer::UpdateCloudBuffer(int i, std::vector<float>& vertices) {
  clouds[i].UpdateArrayBuffer(vertices);
}

void GLRenderer::Clear() {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void GLRenderer::DrawMesh(int i, Rcpp::NumericVector p, Rcpp::NumericVector q) {
  meshes[i].Draw(meshShaderProgram, p, q);
}

void GLRenderer::DrawCloud(int i, Rcpp::NumericVector p, Rcpp::NumericVector q) {
  clouds[i].Draw(cloudShaderProgram, p, q);
}

void GLRenderer::Update() {
  glfwSwapBuffers(window);
  glfwPollEvents();
}

std::vector<int> GLRenderer::GetInputs() {
  std::vector<int> output;
  for (int i = GLFW_KEY_SPACE; i <= GLFW_KEY_LAST; i++) {
    if (glfwGetKey(window, i)) {
      output.push_back(i);
    }
  }
  return output;
}

void GLRenderer::FramerateLimit(int framerate) {
  double currTime = glfwGetTime();
  while (currTime - prevTime <= 1.0 / framerate) {
    currTime = glfwGetTime();
  }
  prevTime = currTime;
}

void GLRenderer::Delete() {
  for (Mesh mesh : meshes) mesh.Delete();
  for (Cloud cloud : clouds) cloud.Delete();
  glDeleteProgram(meshShaderProgram);
  glDeleteProgram(cloudShaderProgram);
  
  // Terminate GLFW
  glfwTerminate();
}

std::string GLRenderer::GetFileContents(const char* filename) {
  std::ifstream in(filename, std::ios::binary);
  if (in)
  {
    std::string contents;
    in.seekg(0, std::ios::end);
    contents.resize(in.tellg()); 
    in.seekg(0, std::ios::beg);
    in.read(&contents[0], contents.size());
    in.close();

    return contents;
  }
  Rcpp::Rcout << "ERROR: NO FILE FOUND: " << filename << std::endl;
  return "";
}

void GLRenderer::SetLights(std::vector<float> lightdata) {
  int data_size = lightdata.size();
  int nlights = data_size / 9;
  glUniform1fv(glGetUniformLocation(meshShaderProgram, "lightArray"), data_size, lightdata.data());
  glUniform1i(glGetUniformLocation(meshShaderProgram, "nlights"), nlights);
}

void GLRenderer::SetCamera(Rcpp::NumericVector p, Rcpp::NumericVector q, float FOVdeg, float aspect) {
  glUniform3f(glGetUniformLocation(meshShaderProgram, "camPos"), p[0], p[1], p[2]);
  glUniform4f(glGetUniformLocation(meshShaderProgram, "camQuat"), q[1], q[2], q[3], q[0]);
  glm::mat4 projection = glm::perspective(glm::radians(FOVdeg), aspect, 0.1f, 100.0f);
  glUniformMatrix4fv(glGetUniformLocation(meshShaderProgram, "projMat"), 1, GL_FALSE, glm::value_ptr(projection));
}

bool GLRenderer::WindowShouldClose() {
  return glfwWindowShouldClose(window);
}

void GLRenderer::SaveImage(const char* filepath, int width, int height) {
  GLsizei nrChannels = 3;
  GLsizei stride = nrChannels * width;
  stride += (stride % 4) ? (4 - stride % 4) : 0;
  GLsizei bufferSize = stride * height;
  std::vector<char> buffer(bufferSize);
  glPixelStorei(GL_PACK_ALIGNMENT, 4);
  glReadBuffer(GL_FRONT);
  glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, buffer.data());
  stbi_flip_vertically_on_write(true);
  stbi_write_png(filepath, width, height, nrChannels, buffer.data(), stride);
}
