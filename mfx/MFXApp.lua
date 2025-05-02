local ffi = require"ffi"
local sdl = require"sdl2_ffi"
local gllib = require"gl"
local ig = require"imgui.sdl"

MFXApp = {}

setmetatable(MFXApp, {
  __call = function(self, name)
  return setmetatable({
    name = name,
    user_event = nil,
    user_loop = nil,
  }, {__index = MFXApp})
  end
})

function MFXApp.getName(self)
  return self.name
end


function MFXApp.init_gui(self)
  self:init_sdl()
  self:init_imgui()
  require("imgui.sdl").ImPlot_CreateContext()
end

function MFXApp.init_sdl(self)
  gllib.set_loader(sdl)
  self.gl, glc, glu, glext = gllib.libraries()

  if (sdl.init(sdl.INIT_VIDEO+sdl.INIT_TIMER+sdl.INIT_GAMECONTROLLER) ~= 0) then
    print(string.format("Error: %s\n", sdl.getError()));
    return -1;
  end

  sdl.gL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE);
  sdl.gL_SetAttribute(sdl.GL_DOUBLEBUFFER, 1);
  sdl.gL_SetAttribute(sdl.GL_DEPTH_SIZE, 24);
  sdl.gL_SetAttribute(sdl.GL_STENCIL_SIZE, 8);
  sdl.gL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3);
  sdl.gL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 0);
  local current = ffi.new("SDL_DisplayMode[1]")
  sdl.getCurrentDisplayMode(0, current);
  window = sdl.createWindow(self.name, sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 1280, 720, sdl.WINDOW_OPENGL+sdl.WINDOW_RESIZABLE); 
  gl_context = sdl.gL_CreateContext(window);
  sdl.gL_SetSwapInterval(1); -- Enable vsync
end


function MFXApp.init_imgui(self)
  self.ig_Impl = ig.Imgui_Impl_SDL_opengl3()

  self.ig_Impl:Init(window, gl_context)

  self.igio = ig.GetIO()
  self.igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableKeyboard + self.igio.ConfigFlags 
  self.igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableGamepad + self.igio.ConfigFlags

  local remap = "1900c3ea010000000100000001010000,odroidgo3_joypad,a:b1,b:b0,dpdown:b13,dpleft:b14,+lefty:+a1,-leftx:-a0,+leftx:+a0,-lefty:-a1,leftshoulder:b4,leftstick:b16,lefttrigger:b6,dpright:b15,+righty:+a3,-rightx:-a2,+rightx:+a2,-righty:-a3,rightshoulder:b5,rightstick:b10,righttrigger:b7,back:b8,start:b9,dpup:b12,x:b2,y:b3,guide:b11,platform:Linux"
  local res = sdl.SDL_GameControllerAddMapping(remap)
end

function MFXApp.destroy_delete_quit(self)
  -- Cleanup
  self.ig_Impl:destroy()
  
  sdl.gL_DeleteContext(gl_context);
  sdl.destroyWindow(window);
  sdl.quit();
end

function MFXApp.run(self)
  while (not done) do
    
    self:user_event()
    
    --standard rendering
    sdl.gL_MakeCurrent(window, gl_context);
    self.gl.glViewport(0, 0, self.igio.DisplaySize.x, self.igio.DisplaySize.y);
    self.gl.glClear(glc.GL_COLOR_BUFFER_BIT)
    
    self.ig_Impl:NewFrame()
    
    self:user_loop()
    
    self.ig_Impl:Render()
    sdl.gL_SwapWindow(window);
  end
  self:destroy_delete_quit()
end

return MFXApp