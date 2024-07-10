#ifndef MESH
#define MESH

#include <glad/glad.h>
#include <vector>
#include "Rcpp.h"

class Mesh {
public:
  
  Mesh(std::vector<float>& vertices, std::vector<GLuint>& indices) {
    
    num_indices = indices.size();
    array_size = vertices.size() * sizeof(float);
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
    
    glBindVertexArray(VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, array_size, vertices.data(), GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, num_indices * sizeof(GLuint), indices.data(), GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 10 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 10 * sizeof(float), (void*)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);
    
    glBindVertexArray(0);
  }
  
  void Draw(GLuint shaderProgram, Rcpp::NumericVector p, Rcpp::NumericVector q) {
    glUniform3f(glGetUniformLocation(shaderProgram, "objPos"), p[0], p[1], p[2]);
    glUniform4f(glGetUniformLocation(shaderProgram, "objQuat"), q[1], q[2], q[3], q[0]);
    
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, num_indices, GL_UNSIGNED_INT, 0);
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
    glDeleteBuffers(1, &EBO);
  }
  
private:
  GLuint VBO, VAO, EBO;
  int num_indices, array_size;
};

#endif