#include "GLRenderer.h"

using namespace Rcpp;

RCPP_MODULE(GLRenderer) {
  class_<GLRenderer>("GLRenderer")
  .constructor<const char*, int, int>()
  .method("InitMeshShaderProgram", &GLRenderer::InitMeshShaderProgram)
  .method("InitMesh", &GLRenderer::InitMesh)
  .method("UpdateMeshBuffer", &GLRenderer::UpdateMeshBuffer)
  .method("Clear", &GLRenderer::Clear)
  .method("UseMeshShaderProgram", &GLRenderer::UseMeshShaderProgram)
  .method("DrawMesh", &GLRenderer::DrawMesh)
  .method("Update", &GLRenderer::Update)
  .method("FramerateLimit", &GLRenderer::FramerateLimit)
  .method("Delete", &GLRenderer::Delete)
  .method("GetInputs", &GLRenderer::GetInputs)
  .method("SetCamera", &GLRenderer::SetCamera)
  .method("SetLights", &GLRenderer::SetLights)
  .method("WindowShouldClose", &GLRenderer::WindowShouldClose)
  .method("SaveImage", &GLRenderer::SaveImage)
  ;
}
