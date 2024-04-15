update_renderer <- function(renderer, camera){
  
  do.call(renderer$SetCameraPosition, as.list(position(camera)))
  do.call(renderer$SetCameraOrientation, as.list(direction(camera)))
  do.call(renderer$SetCameraUp, as.list(skewer(camera, "up")))
  
  renderer$Clear()
  renderer$Render(camera$fov)
  renderer$Update()
  renderer
}