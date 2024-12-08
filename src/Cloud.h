#ifndef CLOUD
#define CLOUD

#include "Mesh.h"

class Cloud {
public:
  
  Cloud(std::vector<float>& vertices) {
    
    num_indices = vertices.size() / 7;
    array_size = vertices.size() * sizeof(float);
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, array_size, vertices.data(), GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    glBindVertexArray(0);
  }
  
  void Draw(GLuint shaderProgram, Rcpp::NumericVector p, Rcpp::NumericVector q) {
    glUniform3f(glGetUniformLocation(shaderProgram, "objPos"), p[0], p[1], p[2]);
    glUniform4f(glGetUniformLocation(shaderProgram, "objQuat"), q[1], q[2], q[3], q[0]);
    
    glBindVertexArray(VAO);
    glDrawArrays(GL_POINTS, 0, num_indices);
    glBindVertexArray(0);
  }
  
  void UpdateArrayBuffer(std::vector<float>& vertices) {
    // orphan the buffer so that we can write new data without waiting for it to be unused
    // as soon as it's finished being used it will automatically be freed so we don't care about it anymore
    glBufferData(GL_ARRAY_BUFFER, array_size, NULL, GL_STREAM_DRAW);
    
    // fill the newly-allocated buffer with our new data
    glBufferData(GL_ARRAY_BUFFER, array_size, vertices.data(), GL_STREAM_DRAW);
  }
  
  void Delete() {
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
  }
  
private:
  GLuint VBO, VAO;
  int num_indices, array_size;
};

#endif