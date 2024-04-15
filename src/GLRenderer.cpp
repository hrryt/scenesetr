#include "GLRenderer.h"
#include <iostream>
#include <vector>

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
    
    glEnable(GL_DEPTH_TEST);
}

void CompileErrors(unsigned int shader, const char* type) {
  GLint has_compiled;
  char info_log[1024];
  if (type != "PROGRAM") {
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

void GLRenderer::InitShaderProgram(const char* vertex_shader, const char* fragment_shader) {
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
  shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  
  // Delete shaders (we no longer need them after linking)
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
}

void GLRenderer::InitBuffers(std::vector<float>& vertices, std::vector<GLuint>& indices) {
  num_indices = indices.size();
  
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);
  glGenBuffers(1, &EBO);
  
  glBindVertexArray(VAO);
  
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(float), vertices.data(), GL_STATIC_DRAW);
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(GLuint), indices.data(), GL_STATIC_DRAW);
  
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
  glEnableVertexAttribArray(1);
  
  glBindVertexArray(0);
}

void GLRenderer::Clear() {
  // Render here, clear the buffer
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void GLRenderer::Render(int FOVdeg) {
    // Use the shader program
    glUseProgram(shaderProgram);
    
    glUniform1f(glGetUniformLocation(shaderProgram, "time"), glfwGetTime());
    glUniform1f(glGetUniformLocation(shaderProgram, "spin_time"), glfwGetTime());
    float new_col = (sin((glfwGetTime()) / 1.0f) + 1) / 2.0f;
    float new_col2 = (sin((glfwGetTime()+2) / 1.0f) + 1) / 2.0f;
    float new_col3 = (sin((glfwGetTime()+4) / 1.0f) + 1) / 2.0f;
    glUniform4fv(glGetUniformLocation(shaderProgram, "colour_1"), 1, glm::value_ptr(glm::vec4(new_col,0.0,0.0,1.0)));
    glUniform4fv(glGetUniformLocation(shaderProgram, "colour_2"), 1, glm::value_ptr(glm::vec4(0.0, new_col2, 0.0, 1.0)));
    glUniform4fv(glGetUniformLocation(shaderProgram, "colour_3"), 1, glm::value_ptr(glm::vec4(0.0, 0.0, new_col3, 1.0)));
    glUniform1f(glGetUniformLocation(shaderProgram, "contrast"), 0.5);
    glUniform1f(glGetUniformLocation(shaderProgram, "spin_amount"), 0.5);
    glUniform1f(glGetUniformLocation(shaderProgram, "PIXEL_SIZE_FAC"), 700);
    
    // camera.Inputs(window);
    camera.updateMatrix(FOVdeg, 0.1f, 100.0f);
    
    camera.Matrix(shaderProgram, "camMatrix");

    // Bind the VAO
    glBindVertexArray(VAO);

    // Draw the triangle
    glDrawElements(GL_TRIANGLES, num_indices, GL_UNSIGNED_INT, 0);

    // Unbind the VAO
    glBindVertexArray(0);
}

void GLRenderer::Update() {
    // Swap front and back buffers
    glfwSwapBuffers(window);

    // Poll for and process events
    glfwPollEvents();
}

std::vector<int> GLRenderer::GetInputs() {
    std::vector<int> output;
    for (int i = 32; i <= GLFW_KEY_LAST; i++) {
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
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    glDeleteProgram(shaderProgram);

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

void GLRenderer::SetCameraPosition(float x, float y, float z) {
  camera.Position = glm::vec3(x, y, z);
}

void GLRenderer::SetCameraOrientation(float x, float y, float z) {
  camera.Orientation = glm::vec3(x, y, z);
}

void GLRenderer::SetCameraUp(float x, float y, float z) {
  camera.Up = glm::vec3(x, y, z);
}

void GLRenderer::SetCameraResolution(float width, float height){
  camera.width = width;
  camera.height = height;
}

void GLRenderer::saveImage(const char* filepath, int width, int height) {
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
